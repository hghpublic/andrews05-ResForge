import Cocoa

class MenuItem: NSObject {
    
    static let nameDidChangeNotification = Notification.Name("MENUItemNameDidChangeNotification")
    static let keyEquivalentDidChangeNotification = Notification.Name("MENUItemKeyEquivalentDidChangeNotification")
    static let markCharacterDidChangeNotification = Notification.Name("MENUItemMarkCharacterDidChangeNotification")
    static let enabledDidChangeNotification = Notification.Name("MENUItemEnabledDidChangeNotification")
    
    var name = "" {
        didSet {
            NotificationCenter.default.post(name: MenuItem.nameDidChangeNotification, object: self)
        }
    }
    var iconID = Int(0)
    var keyEquivalent = "" {
        didSet {
            NotificationCenter.default.post(name: MenuItem.keyEquivalentDidChangeNotification, object: self)
        }
    }
    var markCharacter = "" {
        didSet {
            NotificationCenter.default.post(name: MenuItem.markCharacterDidChangeNotification, object: self)
        }
    }
    var styleByte = UInt8(0)
    var menuCommand = UInt32(0)
    
    var isEnabled: Bool = true {
        didSet {
            NotificationCenter.default.post(name: MenuItem.enabledDidChangeNotification, object: self)
        }
    }
    var hasKeyEquivalent: Bool {
        return !keyEquivalent.isEmpty
    }
    
    var isItem: Bool { return true }
    
    internal init(name: String = "", iconID: Int = Int(0), keyEquivalent: String = "", markCharacter: String = "", styleByte: UInt8 = UInt8(0), menuCommand: UInt32 = UInt32(0), isEnabled: Bool = true) {
        self.name = name
        self.iconID = iconID
        self.keyEquivalent = keyEquivalent
        self.markCharacter = markCharacter
        self.styleByte = styleByte
        self.menuCommand = menuCommand
        self.isEnabled = isEnabled
    }
    
}

extension MenuItem {
    
    override func value(forKey key: String) -> Any? {
        if key == "markCharacter" {
            return markCharacter
        } else if key == "keyEquivalent" {
            return keyEquivalent
        } else if key == "name" {
            return name
        } else if key == "isEnabled" {
            return isEnabled
        } else if key == "textColor" {
            return isEnabled ? NSColor.black : NSColor.lightGray
        } else if key == "hasKeyEquivalent" {
            return hasKeyEquivalent
        } else {
            return super.value(forKey: key)
        }
    }
    
    override func setValue(_ value: Any?, forKey key: String) {
        if key == "markCharacter" {
            markCharacter = value as? String ?? ""
        } else if key == "keyEquivalent" {
            keyEquivalent = value as? String ?? ""
        } else if key == "name" {
            name = value as? String ?? ""
        } else if key == "isEnabled" {
            isEnabled = value as? Bool ?? true
        } else {
            super.setValue(value, forKey: key)
        }
    }
    
}

extension MenuItem {
    override var description: String {
        return "\(self.className)(name = \"\(name)\", keyEquivalent = \"\(keyEquivalent)\", markCharacter = \"\(markCharacter)\")"
    }
}
