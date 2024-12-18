//
//  BoardSquareView.swift
//  GG
//
//  Created by Vito Royeca on 10/31/24.
//

import SwiftUI

struct BoardSquareView: View {
    let boardPosition: GGBoardPosition?
    @Binding var draggedPosition: GGBoardPosition?
    var dropDelegate: DropDelegate?
    let revealUnit: Bool
    let color: Color
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        if let dropDelegate {
            createMainView()
                .onDrop(of: [.boardPosition], delegate: dropDelegate)
        } else {
            createMainView()
        }
    }
}

extension BoardSquareView {
    
    @ViewBuilder
    func createMainView() -> some View {
        let player =  boardPosition?.player
        let rank =  boardPosition?.rank
        let action = boardPosition?.action
        let isLastAction = boardPosition?.isLastAction ?? false
        
        ZStack {
            color
            
            if let rank {
                if dropDelegate != nil {
                    createUnitView(player: player,
                                   rank: rank,
                                   revealUnit: revealUnit)
                    .onDrag {
                        self.draggedPosition = boardPosition
                        return NSItemProvider()
                    }
                } else {
                    createUnitView(player: player,
                                   rank: rank,
                                   revealUnit: revealUnit)
                }
            }
            
            if let action {
                let name = isLastAction ? action.lastIconName : action.possibleIconName
                let actionColor: Color = isLastAction ?
                    ((player?.isBottomPlayer ?? false) ? .white : .black) :
                    .white
                
                createActionView(systemIcon: name,
                                 color: actionColor)
                
            }
        }
        .frame(width: width, height: height)
    }
}

extension BoardSquareView {
    
    @ViewBuilder
    func createUnitView(player: GGPlayer?,
                        rank: GGRank,
                        revealUnit: Bool) -> some View {
        
        let colorName = (player?.isBottomPlayer ?? true) ? "white" : "black"
        let borderColor: Color = (player?.isBottomPlayer ?? true) ? .black : .white
        let name = revealUnit ? "\(rank.iconName)-\(colorName)" : "blank-\(colorName)"
        
        if revealUnit {
            Image(name)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(1) // Inner corner radius
                .padding(1) // Width of the border
                .background(borderColor) // Color of the border
                .cornerRadius(1) // Outer corner radius
                .padding(.leading, 2)
                .padding(.trailing, 2)
        } else {
            Image(name)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(1) // Outer corner radius
                .padding(.leading, 2)
                .padding(.trailing, 2)
        }
        
    }
}

extension BoardSquareView {

    @ViewBuilder
    func createActionView(systemIcon: String, color: Color) -> some View {
        Image(systemName: systemIcon)
            .resizable()
            .foregroundStyle(color)
            .aspectRatio(contentMode: .fit)
            .frame(width: width-10, height: height-10)
    }
}

#Preview {
    let boardPosition = GGBoardPosition(row: 0,
                                        column: 0,
                                        rank: .flag)
    
    BoardSquareView(boardPosition: boardPosition,
                    draggedPosition: .constant(nil),
                    dropDelegate: nil,
                    revealUnit: true,
                    color: GGConstants.gameViewBoardSquareColor,
                    width: 40,
                    height: 20)
}
