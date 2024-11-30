import AppKit
import RFSupport

class StellarView: NSView {
    let resource: Resource
    let manager: RFEditorManager
    let isEnabled: Bool
    private(set) var position = NSPoint.zero
    private(set) var image: NSImage? = nil
    private var attributes: [NSAttributedString.Key: Any] {
        [.foregroundColor: NSColor.white, .font: NSFont.systemFont(ofSize: 11)]
    }
    private var systemView: SystemMapView? {
        superview as? SystemMapView
    }
    private var showName = false {
        didSet {
            if oldValue != showName {
                needsDisplay = true
            }
        }
    }
    var point = NSPoint.zero {
        didSet {
            frame.center = point
            needsDisplay = showName
        }
    }
    var isHighlighted = false {
        didSet {
            if oldValue != isHighlighted {
                needsDisplay = true
            }
        }
    }

    init?(_ stellar: Resource, manager: RFEditorManager, isEnabled: Bool) {
        self.resource = stellar
        self.manager = manager
        self.isEnabled = isEnabled
        super.init(frame: .zero)
        do {
            try self.read()
        } catch {
            return nil
        }
    }

    func read() throws {
        let reader = BinaryDataReader(resource.data)
        position.x = Double(try reader.read() as Int16)
        position.y = Double(try reader.read() as Int16)
        let spinId = Int(try reader.read() as Int16) + 1000
        try? self.loadGraphic(spinId)
    }

    private func loadGraphic(_ spinId: Int) throws {
        if let spinResource = manager.findResource(type: ResourceType("spïn"), id: spinId, currentDocumentOnly: false) {
            let spinReader = BinaryDataReader(spinResource.data)
            let spriteId = Int(try spinReader.read() as Int16)

            // Use the preview provider to obtain an NSImage from the resources the spïn might point to -- try rlëD then fall back to PICT
            if let spriteResource = manager.findResource(type: ResourceType("rlëD"), id: spriteId, currentDocumentOnly: false) ?? manager.findResource(type: ResourceType("PICT"), id: spriteId, currentDocumentOnly: false) {
                spriteResource.preview { img in
                    self.image = img
                    self.updateFrame()
                    self.needsDisplay = true
                }
            }
        }
    }

    override func updateTrackingAreas() {
        for trackingArea in self.trackingAreas {
            self.removeTrackingArea(trackingArea)
        }
        let tracking = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .activeInKeyWindow, .enabledDuringMouseDrag], owner: self, userInfo: nil)
        self.addTrackingArea(tracking)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateFrame() {
        let baseSize = image?.size ?? NSSize(width: 80, height: 80)
        if let size = systemView?.transform.transform(baseSize) {
            frame.size.width = max(size.width, 8)
            frame.size.height = max(size.height, 8)
        }
        if let point = systemView?.transform.transform(position) {
            self.point = point
        }
    }

    func move(to newPos: NSPoint) {
        let curPos = position
        position = NSPoint(x: newPos.x.rounded(), y: newPos.y.rounded())
        self.updateFrame()
        self.save()
        undoManager?.registerUndo(withTarget: self) { $0.move(to: curPos) }
    }

    private func save() {
        guard resource.data.count >= 2 * 2 else {
            return
        }
        let writer = BinaryDataWriter()
        writer.data = resource.data
        writer.write(Int16(position.x), at: 0)
        writer.write(Int16(position.y), at: 2)
        systemView?.isSavingStellar = true
        resource.data = writer.data
        systemView?.isSavingStellar = false
    }

    override func draw(_ dirtyRect: NSRect) {
        guard dirtyRect.intersects(bounds) else {
            return
        }

        if let image {
            image.draw(in: NSRect(origin: .zero, size: frame.size))
        } else {
            NSColor.black.setFill()
            if isEnabled {
                NSColor.blue.setStroke()
            } else {
                NSColor.gray.setStroke()
            }
            let path = NSBezierPath(ovalIn: bounds.insetBy(dx: 1, dy: 1))
            path.fill()
            path.stroke()
        }

        if isHighlighted {
            // Draw a highlighted outline around the stellar
            NSColor.selectedContentBackgroundColor.setStroke()
            let outline = NSBezierPath(roundedRect: bounds, xRadius: 6, yRadius: 6)
            outline.lineWidth = 2
            outline.stroke()
        }

        // Show name and position - get this from frame center in case of dragging
        if showName, let position = systemView?.transform.inverted()?.transform(frame.center) {
            let x = Int(position.x.rounded())
            let y = Int(position.y.rounded())
            let label = "\(resource.name): \(x),\(y)"
            var rect = label.boundingRect(with: .zero, attributes: attributes)
            rect.origin.x = bounds.maxX + 4
            rect.origin.y = bounds.midY - 4
            rect.size.height = 8
            NSColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.7).setFill()
            NSBezierPath(roundedRect: rect.insetBy(dx: -2, dy: -3), xRadius: 2, yRadius: 2).fill()
            label.draw(with: rect, attributes: attributes)
        }
    }

    // MARK: - Mouse events

    override func mouseDown(with event: NSEvent) {
        if isEnabled {
            systemView?.mouseDown(stellar: self, with: event)
        }
    }

    override func mouseDragged(with event: NSEvent) {
        if isEnabled {
            systemView?.mouseDragged(stellar: self, with: event)
        }
    }

    override func mouseUp(with event: NSEvent) {
        if isEnabled {
            systemView?.mouseUp(stellar: self, with: event)
        }
    }

    // Show name and position on hover
    override func mouseEntered(with event: NSEvent) {
        showName = true
    }
    override func mouseExited(with event: NSEvent) {
        showName = false
    }
}