import UIKit

class LayerView: UIView
{
    private let caLayer: CALayer
    
    init(layer: CALayer)
    {
        self.caLayer = layer
        super.init(frame: UIScreen.main.bounds)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews()
    {
        caLayer.frame = self.bounds
    }
}
