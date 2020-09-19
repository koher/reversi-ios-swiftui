import UIKit
import SwiftyReversi
import ReversiLogics

private let lineWidth: CGFloat = 2

public class _BoardView: UIView {
    private var cellViews: [_CellView] = []
    private var actions: [CellSelectionAction] = []
    
    public let width: Int = 8
    public let height: Int = 8
    
    public let xRange: Range<Int>
    public let yRange: Range<Int>
    
    public weak var delegate: _BoardViewDelegate?
    
    private var animationCanceller: AnimationCanceller?
    
    override public init(frame: CGRect) {
        xRange = 0 ..< width
        yRange = 0 ..< height
        super.init(frame: frame)
        setUp()
    }
    
    required public init?(coder: NSCoder) {
        xRange = 0 ..< width
        yRange = 0 ..< height
        super.init(coder: coder)
        setUp()
    }
    
    private func setUp() {
        self.backgroundColor = UIColor(named: "DarkColor")!
        
        let cellViews: [_CellView] = (0 ..< (width * height)).map { _ in
            let cellView = _CellView()
            cellView.translatesAutoresizingMaskIntoConstraints = false
            return cellView
        }
        self.cellViews = cellViews
        
        cellViews.forEach(self.addSubview(_:))
        for i in cellViews.indices.dropFirst() {
            NSLayoutConstraint.activate([
                cellViews[0].widthAnchor.constraint(equalTo: cellViews[i].widthAnchor),
                cellViews[0].heightAnchor.constraint(equalTo: cellViews[i].heightAnchor),
            ])
        }
        
        NSLayoutConstraint.activate([
            cellViews[0].widthAnchor.constraint(equalTo: cellViews[0].heightAnchor),
        ])
        
        for y in yRange {
            for x in xRange {
                let topNeighborAnchor: NSLayoutYAxisAnchor
                if let cellView = cellViewAt(x: x, y: y - 1) {
                    topNeighborAnchor = cellView.bottomAnchor
                } else {
                    topNeighborAnchor = self.topAnchor
                }
                
                let leftNeighborAnchor: NSLayoutXAxisAnchor
                if let cellView = cellViewAt(x: x - 1, y: y) {
                    leftNeighborAnchor = cellView.rightAnchor
                } else {
                    leftNeighborAnchor = self.leftAnchor
                }
                
                let cellView = cellViewAt(x: x, y: y)!
                NSLayoutConstraint.activate([
                    cellView.topAnchor.constraint(equalTo: topNeighborAnchor, constant: lineWidth),
                    cellView.leftAnchor.constraint(equalTo: leftNeighborAnchor, constant: lineWidth),
                ])
                
                if y == height - 1 {
                    NSLayoutConstraint.activate([
                        self.bottomAnchor.constraint(equalTo: cellView.bottomAnchor, constant: lineWidth),
                    ])
                }
                if x == width - 1 {
                    NSLayoutConstraint.activate([
                        self.rightAnchor.constraint(equalTo: cellView.rightAnchor, constant: lineWidth),
                    ])
                }
            }
        }
        
        reset()
        
        for y in yRange {
            for x in xRange {
                let cellView: _CellView = cellViewAt(x: x, y: y)!
                let action = CellSelectionAction(boardView: self, x: x, y: y)
                actions.append(action) // To retain the `action`
                cellView.addTarget(action, action: #selector(action.selectCell), for: .touchUpInside)
            }
        }
    }
    
    public func reset() {
        for y in  yRange {
            for x in xRange {
                setDisk(nil, atX: x, y: y, animated: false)
            }
        }
        
        setDisk(.light, atX: width / 2 - 1, y: height / 2 - 1, animated: false)
        setDisk(.dark, atX: width / 2, y: height / 2 - 1, animated: false)
        setDisk(.dark, atX: width / 2 - 1, y: height / 2, animated: false)
        setDisk(.light, atX: width / 2, y: height / 2, animated: false)
    }
    
    private func cellViewAt(x: Int, y: Int) -> _CellView? {
        guard xRange.contains(x) && yRange.contains(y) else { return nil }
        return cellViews[y * width + x]
    }
    
    public func diskAt(x: Int, y: Int) -> Disk? {
        cellViewAt(x: x, y: y)?.disk
    }
    
    public func setDisk(_ disk: Disk?, atX x: Int, y: Int, animated isAnimated: Bool, completion: ((Bool) -> Void)? = nil) {
        precondition(Thread.isMainThread)
        guard let cellView = cellViewAt(x: x, y: y) else {
            preconditionFailure() // FIXME: Add a message.
        }
        cellView.setDisk(disk, animated: isAnimated, completion: completion)
    }
    
    public var board: Board {
        var board: Board = .init(width: width, height: height)
        for y in yRange {
            for x in xRange {
                board[x, y] = cellViewAt(x: x, y: y)!.disk
            }
        }
        return board
    }
    
    public func setBoard(_ board: Board, animated isAnimated: Bool, completion: ((Bool) -> Void)? = nil) {
        precondition(Thread.isMainThread)
        precondition(board.width == width)
        precondition(board.height == height)
        
        animationCanceller?.cancel()
        let canceller: AnimationCanceller = .init()
        animationCanceller = canceller
        
        let boardDiff: BoardDiff = .init(from: self.board, to: board)
        applyBoardDiffResult(boardDiff.result[...], animated: isAnimated, canceller: canceller, completion: completion)
    }
    
    private func applyBoardDiffResult(_ diff: ArraySlice<(disk: Disk?, x: Int, y: Int)>, animated isAnimated: Bool, canceller: AnimationCanceller, completion: ((Bool) -> Void)?) {
        if canceller.isCancelled { return }
        guard let (disk, x, y) = diff.first else {
            animationCanceller = nil
            completion?(true)
            return
        }
        setDisk(disk, atX: x, y: y, animated: isAnimated) { [weak self] isFinished in
            guard let self = self else { return }
            guard isFinished else {
                self.animationCanceller = nil
                completion?(isFinished)
                return
            }
            self.applyBoardDiffResult(diff[(diff.startIndex + 1)...], animated: isAnimated, canceller: canceller, completion: completion)
        }
    }
}

public protocol _BoardViewDelegate: AnyObject {
    func boardView(_ boardView: _BoardView, didSelectCellAtX x: Int, y: Int)
}

private final class CellSelectionAction: NSObject {
    private weak var boardView: _BoardView?
    let x: Int
    let y: Int
    
    init(boardView: _BoardView, x: Int, y: Int) {
        self.boardView = boardView
        self.x = x
        self.y = y
    }
    
    @objc func selectCell() {
        guard let boardView = boardView else { return }
        boardView.delegate?.boardView(boardView, didSelectCellAtX: x, y: y)
    }
}

private final class AnimationCanceller {
    private(set) var isCancelled: Bool = false
    func cancel() {
        isCancelled = true
    }
}
