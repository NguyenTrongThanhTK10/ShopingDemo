import AppKit
import Foundation

// Run from the repository root with: swift tool/generate_app_icons.swift
let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let coral = NSColor(calibratedRed: 168 / 255, green: 94 / 255, blue: 82 / 255, alpha: 1)

func png(size: Int) -> Data {
  let bitmap = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: size,
    pixelsHigh: size,
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
  )!
  NSGraphicsContext.saveGraphicsState()
  NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
  let context = NSGraphicsContext.current!.cgContext
  context.setAllowsAntialiasing(true)
  context.setShouldAntialias(true)
  context.scaleBy(x: CGFloat(size) / 1024, y: CGFloat(size) / 1024)

  coral.setFill()
  NSRect(x: 0, y: 0, width: 1024, height: 1024).fill()

  NSColor.white.setFill()
  NSColor.white.setStroke()
  let basket = NSBezierPath()
  basket.move(to: NSPoint(x: 350, y: 638))
  basket.line(to: NSPoint(x: 770, y: 638))
  basket.line(to: NSPoint(x: 711, y: 466))
  basket.line(to: NSPoint(x: 391, y: 466))
  basket.close()
  basket.fill()

  let frame = NSBezierPath()
  frame.lineWidth = 43
  frame.lineCapStyle = .round
  frame.lineJoinStyle = .round
  frame.move(to: NSPoint(x: 250, y: 710))
  frame.line(to: NSPoint(x: 326, y: 710))
  frame.line(to: NSPoint(x: 403, y: 399))
  frame.line(to: NSPoint(x: 725, y: 399))
  frame.stroke()

  NSBezierPath(ovalIn: NSRect(x: 425, y: 278, width: 74, height: 74)).fill()
  NSBezierPath(ovalIn: NSRect(x: 651, y: 278, width: 74, height: 74)).fill()

  NSGraphicsContext.restoreGraphicsState()
  return bitmap.representation(using: .png, properties: [:])!
}

func write(_ relativePath: String, size: Int) throws {
  let file = root.appendingPathComponent(relativePath)
  try png(size: size).write(to: file)
}

let androidSizes = ["mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192]
for (density, size) in androidSizes {
  try write("android/app/src/main/res/mipmap-\(density)/ic_launcher.png", size: size)
}

let iosDirectory = "ios/Runner/Assets.xcassets/AppIcon.appiconset"
let iosContents = try Data(contentsOf: root.appendingPathComponent("\(iosDirectory)/Contents.json"))
let iosJSON = try JSONSerialization.jsonObject(with: iosContents) as! [String: Any]
for entry in iosJSON["images"] as! [[String: String]] {
  guard let filename = entry["filename"], let points = entry["size"], let scale = entry["scale"] else { continue }
  let pointSize = Double(points.split(separator: "x")[0])!
  let scaleFactor = Double(scale.replacingOccurrences(of: "x", with: ""))!
  try write("\(iosDirectory)/\(filename)", size: Int(pointSize * scaleFactor))
}

let macDirectory = "macos/Runner/Assets.xcassets/AppIcon.appiconset"
for size in [16, 32, 64, 128, 256, 512, 1024] {
  try write("\(macDirectory)/app_icon_\(size).png", size: size)
}

for size in [192, 512] {
  try write("web/icons/Icon-\(size).png", size: size)
  try write("web/icons/Icon-maskable-\(size).png", size: size)
}
try write("web/favicon.png", size: 32)

let windowsSizes = [16, 24, 32, 48, 64, 128, 256]
var ico = Data()
func appendUInt16(_ value: Int) { ico.append(contentsOf: [UInt8(value & 0xff), UInt8((value >> 8) & 0xff)]) }
func appendUInt32(_ value: Int) {
  ico.append(contentsOf: (0..<4).map { UInt8((value >> ($0 * 8)) & 0xff) })
}
appendUInt16(0)
appendUInt16(1)
appendUInt16(windowsSizes.count)
let windowsPNGs = windowsSizes.map { png(size: $0) }
var offset = 6 + windowsSizes.count * 16
for (index, size) in windowsSizes.enumerated() {
  ico.append(UInt8(size == 256 ? 0 : size))
  ico.append(UInt8(size == 256 ? 0 : size))
  ico.append(0)
  ico.append(0)
  appendUInt16(1)
  appendUInt16(32)
  appendUInt32(windowsPNGs[index].count)
  appendUInt32(offset)
  offset += windowsPNGs[index].count
}
for data in windowsPNGs { ico.append(data) }
try ico.write(to: root.appendingPathComponent("windows/runner/resources/app_icon.ico"))

print("Generated shopping cart app icons for Android, iOS, macOS, Windows, and web.")
