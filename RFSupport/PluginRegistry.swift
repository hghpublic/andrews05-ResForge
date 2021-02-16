import Cocoa

public class PluginRegistry {
    public private(set) static var editors: [String: ResForgePlugin.Type] = [:]
    public private(set) static var templateEditor: ResForgePlugin.Type! = nil
    public private(set) static var hexEditor: ResForgePlugin.Type! = nil
    public private(set) static var previewSizes: [String: Int] = [:]
    public private(set) static var packages: [ResForgePluginPackage.Type] = []
    
    /// Register a plugin bundle as an editor for types defined in its info.plist.
    public static func register(_ plugin: Bundle) {
        let pluginClasses: [ResForgePlugin.Type]
        if let mainClass = plugin.principalClass as? ResForgePluginPackage.Type {
            packages.append(mainClass)
            pluginClasses = mainClass.pluginClasses
        } else if let mainClass = plugin.principalClass as? ResForgePlugin.Type {
            pluginClasses = [mainClass]
        } else {
            return
        }
        for pluginClass in pluginClasses {
            for type in pluginClass.editedTypes {
                switch type {
                case "Hex":
                    Self.hexEditor = pluginClass
                case "Template":
                    Self.templateEditor = pluginClass
                default:
                    editors[type] = pluginClass
                    if let previewSize = pluginClass.previewSize(for: type) {
                        previewSizes[type] = previewSize
                    }
                }
            }
        }
    }
    
    /// Return a placeholder name to show for a resource when it has no name.
    public static func placeholderName(for resource: Resource) -> String {
        if let placeholder = editors[resource.type]?.placeholderName(for: resource) {
            return placeholder
        }
        for package in packages {
            if let placeholder = package.placeholderName(for: resource) {
                return placeholder
            }
        }
        
        if resource.id == -16455 {
            // don't bother checking type since there are too many icon types
            return NSLocalizedString("Custom Icon", comment: "")
        }
        
        switch resource.type {
        case "carb":
            if resource.id == 0 {
                return NSLocalizedString("Carbon Identifier", comment: "")
            }
        case "pnot":
            if resource.id == 0 {
                return NSLocalizedString("File Preview", comment: "")
            }
        case "STR ":
            if resource.data.count > 1 {
                do {
                    return try BinaryDataReader(resource.data).readPString()
                } catch {}
            }
        case "STR#":
            if resource.data.count > 3 {
                do {
                    // Read first string at offset 2
                    return try BinaryDataReader(resource.data.dropFirst(2)).readPString()
                } catch {}
            }
        case "TEXT":
            if !resource.data.isEmpty, let string = String(data: resource.data.prefix(100), encoding: .macOSRoman) {
                return string
            }
        case "vers":
            if resource.data.count > 7 {
                do {
                    // Read short version string at offset 6
                    return try BinaryDataReader(resource.data.dropFirst(6)).readPString()
                } catch {}
            }
        default:
            break
        }
        return NSLocalizedString("Untitled Resource", comment: "")
    }
}