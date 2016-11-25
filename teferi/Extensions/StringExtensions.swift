import Foundation
import UIKit
import Darwin

extension String
{
    //MARK: Methods
    
    /**
     Finds the localized string for the provided key in the main bundle and returns it.
     
     - Returns: A localized version of the provided key.
     */
    func translate() -> String
    {
        return NSLocalizedString(self, comment: "")
    }
    
    /**
     Gets a string that contains both bold and regular text.
     
     - Parameter nonBoldTextRange: Range where the text will not be bold.
     
     - Returns: A NSAttributedString containing the desired attributes.
     */
    func getBoldStringWithNonBoldText(_ nonBoldTextRange: NSRange) -> NSAttributedString
    {
        let fontSize = UIFont.systemFontSize
        let attrs = [
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: fontSize),
            NSForegroundColorAttributeName: UIColor.black
        ]
        
        let nonBoldAttribute = [
            NSFontAttributeName: UIFont.systemFont(ofSize: fontSize),
            NSForegroundColorAttributeName: UIColor.black//.withAlphaComponent(0.5)
        ]
        
        let attrStr = NSMutableAttributedString(string: self, attributes: attrs)
        attrStr.setAttributes(nonBoldAttribute, range: nonBoldTextRange)
        
        return attrStr
    }
    
    /**
    Gets a string that contains bold, regular, and alpha-adjusted text
     
     - Parameter nonBoldTextRange: Range where the text will not be bold.
     
     - Parameter alphaRange: Range where the alpha value will be changed
     
     - Parameter alpha: The alpha value of the text in the range.
     
     - Returns: A NSAttributed String containing the desired attributes
    */
    func getBoldStringWithNonBoldTextWithAlpha(nonBoldTextRange: NSRange, alphaRange: NSRange, alpha: CGFloat) -> NSAttributedString
    {
        let fontSize = UIFont.systemFontSize
        //Check for valid alpha value
        guard alpha <= 1.0 || alpha >= 0.0 else
        {
            return NSAttributedString(string: self, attributes: [:])
        }
        
        guard let attrStr = self.getBoldStringWithNonBoldText(nonBoldTextRange).mutableCopy() as? NSMutableAttributedString else
        {
            return NSAttributedString(string: self, attributes: [:])
        }
        
        let alphaAttribute = [
            NSForegroundColorAttributeName: UIColor.black.withAlphaComponent(alpha),
            NSFontAttributeName: UIFont.systemFont(ofSize: fontSize)
        ]
        
        attrStr.setAttributes(alphaAttribute, range: alphaRange)
        
        return attrStr
    }
}
