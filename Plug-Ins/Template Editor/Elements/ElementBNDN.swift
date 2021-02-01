import Cocoa
import RKSupport

// Implements BNDN, LNDN, BIGE, LTLE
class ElementBNDN: Element, GroupElement {
    private let bigEndian: Bool
    
    required init!(type: String, label: String, tooltip: String? = nil) {
        bigEndian = type.first == "B"
        super.init(type: type, label: label, tooltip: tooltip)
        self.rowHeight = 18
        self.visible = !type.hasSuffix("NDN")
    }
    
    func configureGroup(view: NSTableCellView) {
        view.textField?.stringValue = self.displayLabel
    }
    
    override func readData(from reader: BinaryDataReader) throws {
        reader.bigEndian = self.bigEndian
    }
    
    override func writeData(to writer: BinaryDataWriter) {
        writer.bigEndian = self.bigEndian
    }
}
