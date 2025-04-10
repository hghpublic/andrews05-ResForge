import AppKit
import RFSupport

class SelectTemplateController: NSWindowController, NSTextFieldDelegate {
    @IBOutlet var typeList: NSComboBox!
    @IBOutlet var openButton: NSButton!
    private var templates: [String: Resource] = [:]

    override var windowNibName: NSNib.Name? {
        "SelectTemplate"
    }

    func show(_ document: ResourceDocument, type: ResourceType, complete: @escaping (Resource) -> Void) {
        _ = self.window
        let allTemplates = document.editorManager.allResources(ofType: .template)
        for template in allTemplates {
            if templates[template.name] == nil {
                templates[template.name] = template
            }
        }
        let sorted = templates.keys.sorted {
            $0.localizedCompare($1) == .orderedAscending
        }
        typeList.addItems(withObjectValues: sorted)

        if templates[type.code] != nil {
            typeList.stringValue = type.code
            openButton.isEnabled = true
        }
        document.windowForSheet?.beginSheet(self.window!) { modalResponse in
            if modalResponse == .OK, let template = self.templates[self.typeList.stringValue] {
                complete(template)
            }
        }
    }

    func controlTextDidChange(_ obj: Notification) {
        // The text must be one of the options in the list.
        // (A popup menu might seem more appropriate but we want the convenience of being able to type it in.)
        openButton.isEnabled = templates[typeList.stringValue] != nil
    }

    @IBAction func hide(_ sender: AnyObject) {
        self.window?.sheetParent?.endSheet(self.window!, returnCode: sender === openButton ? .OK : .cancel)
    }
}
