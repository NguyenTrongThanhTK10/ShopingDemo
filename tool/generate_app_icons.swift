// Run from the repository root: swift tool/generate_app_icons.swift
// Lumi Market's original mark: a white shopping tote with an orange L.
import CoreGraphics
import Foundation
import ImageIO

let fileManager = FileManager.default
let root = URL(fileURLWithPath: fileManager.currentDirectoryPath)
let orange = CGColor(
  colorSpace: CGColorSpaceCreateDeviceRGB(),
  components: [244 / 255, 90 / 255, 49 / 255, 1]
)!

func render(_ size: Int, transparent: Bool = false) -> Data {
  let context = CGContext(
    data: nil,
    width: size,
    height: size,
    bitsPerComponent: 8,
    bytesPerRow: 0,
    space: CGColorSpaceCreateDeviceRGB(),
    bitmapInfo: (transparent
      ? CGImageAlphaInfo.premultipliedLast
      : CGImageAlphaInfo.noneSkipLast).rawValue
  )!
  context.scaleBy(x: CGFloat(size) / 1024, y: CGFloat(size) / 1024)
  context.setAllowsAntialiasing(true)
  context.setShouldAntialias(true)
  context.interpolationQuality = .high

  if !transparent {
    context.setFillColor(orange)
    context.fill(CGRect(x: 0, y: 0, width: 1024, height: 1024))
  }

  // The handle is drawn behind the bag so both sides meet the body cleanly.
  context.setStrokeColor(CGColor(gray: 1, alpha: 1))
  context.setLineWidth(56)
  context.setLineCap(.round)
  context.setLineJoin(.round)
  context.move(to: CGPoint(x: 389, y: 620))
  context.addLine(to: CGPoint(x: 389, y: 696))
  context.addCurve(
    to: CGPoint(x: 635, y: 696),
    control1: CGPoint(x: 389, y: 795),
    control2: CGPoint(x: 635, y: 795)
  )
  context.addLine(to: CGPoint(x: 635, y: 620))
  context.strokePath()

  let bag = CGPath(
    roundedRect: CGRect(x: 269, y: 245, width: 486, height: 386),
    cornerWidth: 70,
    cornerHeight: 70,
    transform: nil
  )
  context.addPath(bag)
  context.setFillColor(CGColor(gray: 1, alpha: 1))
  context.fillPath()

  // The letter stays legible after the icon is reduced to launcher sizes.
  context.setStrokeColor(orange)
  context.setLineWidth(64)
  context.setLineCap(.round)
  context.setLineJoin(.round)
  context.move(to: CGPoint(x: 452, y: 518))
  context.addLine(to: CGPoint(x: 452, y: 364))
  context.addLine(to: CGPoint(x: 583, y: 364))
  context.strokePath()

  let output = NSMutableData()
  let destination = CGImageDestinationCreateWithData(output, "public.png" as CFString, 1, nil)!
  CGImageDestinationAddImage(destination, context.makeImage()!, nil)
  precondition(CGImageDestinationFinalize(destination))
  return output as Data
}

func write(_ data: Data, to relativePath: String) throws {
  let destination = root.appendingPathComponent(relativePath)
  try fileManager.createDirectory(
    at: destination.deletingLastPathComponent(),
    withIntermediateDirectories: true
  )
  try data.write(to: destination, options: .atomic)
}

func iconEntries(at relativePath: String) throws -> [[String: String]] {
  let data = try Data(contentsOf: root.appendingPathComponent(relativePath))
  let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
  return json["images"] as! [[String: String]]
}

let iosDirectory = "ios/Runner/Assets.xcassets/AppIcon.appiconset"
for entry in try iconEntries(at: "\(iosDirectory)/Contents.json") {
  guard let filename = entry["filename"],
        let side = entry["size"]?.split(separator: "x").first,
        let points = Double(side),
        let scale = Double(entry["scale"]?.replacingOccurrences(of: "x", with: "") ?? "")
  else { continue }
  let pixels = Int((points * scale).rounded())
  try write(render(pixels), to: "\(iosDirectory)/\(filename)")
}

let macDirectory = "macos/Runner/Assets.xcassets/AppIcon.appiconset"
for entry in try iconEntries(at: "\(macDirectory)/Contents.json") {
  guard let filename = entry["filename"],
        let sizeText = filename.split(separator: "_").last?.split(separator: ".").first,
        let pixels = Int(sizeText)
  else { continue }
  try write(render(pixels), to: "\(macDirectory)/\(filename)")
}

let androidSizes = [
  "mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192
]
let adaptiveSizes = [
  "mdpi": 108, "hdpi": 162, "xhdpi": 216, "xxhdpi": 324, "xxxhdpi": 432
]
for (density, pixels) in androidSizes {
  try write(render(pixels),
            to: "android/app/src/main/res/mipmap-\(density)/ic_launcher.png")
}
for (density, pixels) in adaptiveSizes {
  try write(render(pixels, transparent: true),
            to: "android/app/src/main/res/mipmap-\(density)/ic_launcher_foreground.png")
}

try write(render(192), to: "web/icons/Icon-192.png")
try write(render(512), to: "web/icons/Icon-512.png")
try write(render(192), to: "web/icons/Icon-maskable-192.png")
try write(render(512), to: "web/icons/Icon-maskable-512.png")
try write(render(64), to: "web/favicon.png")

// A Windows ICO can contain PNG images for each resolution.
func append16(_ value: Int, to data: inout Data) {
  data.append(UInt8(value & 0xff))
  data.append(UInt8((value >> 8) & 0xff))
}
func append32(_ value: Int, to data: inout Data) {
  for shift in stride(from: 0, through: 24, by: 8) {
    data.append(UInt8((value >> shift) & 0xff))
  }
}
let windowsSizes = [16, 24, 32, 48, 64, 128, 256]
let windowsImages = windowsSizes.map { render($0) }
var ico = Data()
append16(0, to: &ico)
append16(1, to: &ico)
append16(windowsImages.count, to: &ico)
var offset = 6 + windowsImages.count * 16
for (index, image) in windowsImages.enumerated() {
  let pixels = windowsSizes[index]
  ico.append(UInt8(pixels == 256 ? 0 : pixels))
  ico.append(UInt8(pixels == 256 ? 0 : pixels))
  ico.append(0) // palette size
  ico.append(0) // reserved
  append16(1, to: &ico) // color planes
  append16(32, to: &ico) // bits per pixel
  append32(image.count, to: &ico)
  append32(offset, to: &ico)
  offset += image.count
}
for image in windowsImages { ico.append(image) }
try write(ico, to: "windows/runner/resources/app_icon.ico")

print("Generated Lumi Market app icons for Android, iOS, macOS, web and Windows.")
