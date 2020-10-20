import Cocoa
import RKSupport

// Implements LSTB, LSTZ, LSTC
class ElementLSTB: Element {
    var counter: CounterElement?
    private let zeroTerminated: Bool
    private var fixedCount: Bool = false
    private var subElements: ElementList!
    private var entries: [Element]!
    private var tail: ElementLSTB!
    private var singleElement: Element?
    
    override var displayLabel: String {
        let index = tail.entries.firstIndex(of: self)! + 1
        return "\(index)) " + (singleElement?.displayLabel ?? super.displayLabel)
    }
    
    required init(type: String, label: String, tooltip: String? = nil) {
        zeroTerminated = type == "LSTZ"
        super.init(type: type, label: label, tooltip: tooltip)
        self.rowHeight = 18
        self.endType = "LSTE"
    }
    
    override func copy() -> Self {
        let element = (super.copy() as Element) as! Self
        element.subElements = try? subElements?.copy()
        element.checkSingleElement()
        element.fixedCount = fixedCount
        element.tail = tail
        return element
    }
    
    override func configure() throws {
        guard counter != nil || type != "LSTC" else {
            throw TemplateError.invalidStructure(self, NSLocalizedString("Preceeding count element not found.", comment: ""))
        }
        // This item will be the tail
        tail = self
        entries = []
        subElements = try self.parentList.subList(for: self)
        _ = try subElements.copy() // Validate the subElements configuration
        if let counter = counter, counter.type == "FCNT" {
            // Fixed count list, create all the entries now
            self.visible = false
            fixedCount = true
            for _ in 0..<counter.count {
                _ = self.createNext()
            }
        } else {
            entries.append(self)
        }
    }
    
    // If the list entry contains only a single visible element, show that element here while hiding the sub section
    // (this also greatly improves performance with large lists)
    override func configure(view: NSView) {
        singleElement?.configure(view: view)
    }
    
    private func checkSingleElement() {
        if subElements != nil && subElements.count == 1 {
            singleElement = subElements.element(at: 0)
            self.tooltip = singleElement!.tooltip
            self.rowHeight = 22
        }
    }
    
    private func createNext() -> Self {
        // Create a new list entry at the current index (just before self)
        let list = self.copy() as Self
        self.parentList.insert(list)
        tail.entries.append(list)
        return list
    }
    
    override func readData(from reader: BinaryDataReader) throws {
        if fixedCount {
            if tail != self {
                try subElements.readData(from: reader)
            }
            return
        }
        
        entries.removeAll()
        if type == "LSTC" {
            for _ in 0..<counter!.count {
                try self.createNext().subElements.readData(from: reader)
            }
        } else {
            while (reader.position < reader.data.endIndex) {
                if zeroTerminated && reader.data[reader.position] == 0 {
                    try reader.advance(1)
                    break
                }
                try self.createNext().subElements.readData(from: reader)
            }
        }
        entries.append(self)
    }
    
    override func dataSize(_ size: inout Int) {
        if tail != self {
            subElements.dataSize(&size)
        } else if zeroTerminated {
            size += 1
        }
    }
    
    override func writeData(to writer: BinaryDataWriter) {
        if tail != self {
            subElements.writeData(to: writer)
        } else if zeroTerminated {
            writer.advance(1)
        }
    }
    
    // MARK: -
    
    override var hasSubElements: Bool {
        singleElement?.hasSubElements ?? (tail != self)
    }
    
    override var subElementCount: Int {
        singleElement?.subElementCount ?? subElements.count
    }
    
    override func subElement(at index: Int) -> Element {
        return singleElement?.subElement(at: index) ?? subElements.element(at: index)
    }
    
    func allowsCreateListEntry() -> Bool {
        return !fixedCount
    }
    
    func allowsRemoveListEntry() -> Bool {
        return !fixedCount && tail != self
    }
    
    func createListEntry() {
        let list = tail.copy() as ElementLSTB
        parentList.insert(list, before: self)
        tail.entries.insert(list, at: tail.entries.firstIndex(of: self)!)
        tail.counter?.count += 1
    }
    
    func removeListEntry() {
        parentList.remove(self)
        tail.entries.removeAll(where: { $0 == self })
        tail.counter?.count -= 1
    }
}
