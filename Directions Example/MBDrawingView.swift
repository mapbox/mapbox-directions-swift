import UIKit

public protocol MBDrawingViewDelegate: class {
    func drawingView(drawingView: MBDrawingView, didDrawWithPoints points: [CGPoint])
}

public class MBDrawingView: UIView {
    
    private var points: [CGPoint]!
    private var context: CGContext!
    private var strokeColor = UIColor.blue.withAlphaComponent(0.75) {
        didSet {
            context.setStrokeColor(strokeColor.cgColor)
        }
    }
    private var lineWidth: CGFloat = 3 {
        didSet {
            context.setLineWidth(lineWidth)
        }
    }
    
    public weak var delegate: MBDrawingViewDelegate?
    
    public convenience init(frame: CGRect, strokeColor: UIColor, lineWidth: CGFloat) {
        self.init(frame: frame)
        
        self.strokeColor = strokeColor
        self.lineWidth = lineWidth
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    deinit {
        UIGraphicsEndImageContext()
    }
    
    private func setup() {
        backgroundColor = UIColor.clear
        
        points = [CGPoint]()
        
        createContext()
    }
    
    public func reset() {
        points = [CGPoint]()
        
        UIGraphicsEndImageContext();
        
        createContext()
    }
    
    private func createContext() {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        context = UIGraphicsGetCurrentContext()!
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        points.removeAll(keepingCapacity: false)
        
        guard let firstPoint = touches.first?.location(in: self) else { return }
        
        points.append(firstPoint)
        
        context.beginPath()
        context.move(to: firstPoint)
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let lastPoint = points.last else { return }
        context.move(to: lastPoint)
        
        guard let point = touches.first?.location(in: self) else { return }
        
        points.append(point)
        
        context.addLine(to: point)
        context.strokePath()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        
        layer.contents = image.cgImage
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.drawingView(drawingView: self, didDrawWithPoints: points)
    }
}
