//
//  GAmeView.swift
//  GG
//
//  Created by Vito Royeca on 10/22/24.
//

import SwiftUI

struct GameView: View {
    @ObservedObject private var viewModel: GameViewModel
    private var gameType: GameType

    init(gameType: GameType,
         player1Positions: [GGBoardPosition]? = nil,
         player2Positions: [GGBoardPosition]? = nil) {
        self.gameType = gameType
        viewModel = .init(gameType: gameType,
                          player1Positions: player1Positions,
                          player2Positions: player2Positions)
    }

    var body: some View {
        main()
            .onAppear {
                withAnimation {
                    viewModel.start()
                }
            }
    }
    
    @ViewBuilder
    private func main() -> some View {
        GeometryReader { proxy in
            ZStack {
                VStack(spacing: 20) {
                    createCasualtiesView(player: viewModel.player1,
                                         casualties: viewModel.player1Casualties,
                                         revealUnit: viewModel.gameType == .humanVsAI ? viewModel.isGameOver : true,
                                         proxy: proxy)

                    ZStack {
                        createBoardView(proxy: proxy)
                        Text(viewModel.statusText)
                            .foregroundStyle(.red)
                            .font(.largeTitle)
                    }
                    
                    createCasualtiesView(player: viewModel.player2,
                                         casualties: viewModel.player2Casualties,
                                         revealUnit: true,
                                         proxy: proxy)

                    
                }

                VStack {
                    PlayerAreaView(proxy: proxy,
                                   player: viewModel.player1,
                                   viewModel: viewModel)
                    Spacer()
                    PlayerAreaView(proxy: proxy,
                                   player: viewModel.player2,
                                   viewModel: viewModel)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(GGConstants.gameViewBackgroundColor)
        }
    }
    
    @ViewBuilder func createBoardView(proxy: GeometryProxy) -> some View {
        let squareWidth = proxy.size.width / CGFloat(GameViewModel.columns)
        let squareHeight = squareWidth

        Grid(alignment: .topLeading,
             horizontalSpacing: 1,
             verticalSpacing: 1) {
            ForEach(0..<GameViewModel.rows, id: \.self) { row in
                if row == 4 {
                    Divider()
                        .padding(1)
                }
                
                GridRow {
                    ForEach(0..<GameViewModel.columns, id: \.self) { column in
                        let boardPosition = viewModel.boardPositions.isEmpty ?
                            GGBoardPosition(row: 0, column: 0) :
                            viewModel.boardPositions[row][column]
                        let revealUnit = viewModel.gameType == .aiVsAI ?
                            true :
                            ((boardPosition.player?.isBottomPlayer ?? false) ? true : viewModel.isGameOver)
                        let color = GGConstants.gameViewBoardSquareColor

                        BoardSquareView(boardPosition: boardPosition,
                                        draggedPosition: .constant(nil),
                                        dropDelegate: nil,
                                        revealUnit: revealUnit,
                                        color: color,
                                        width: squareWidth,
                                        height: squareHeight)
                            .onTapGesture {
                                withAnimation {
                                    viewModel.doHumanMove(row: row, column: column)
                                }
                            }
                    }
                }

            }
        }
    }
    
    @ViewBuilder func createCasualtiesView(player: GGPlayer,
                                           casualties: [[GGRank]],
                                           revealUnit: Bool,
                                           proxy: GeometryProxy) -> some View {
        let squareWidth = proxy.size.width / CGFloat(GameViewModel.unitCount / 3)
        let squareHeight = squareWidth

        Grid(alignment: .topLeading,
             horizontalSpacing: 1,
             verticalSpacing: 1) {
            
            ForEach(0..<3) { row in
                GridRow {
                    ForEach(0..<7) { column in
                        let rank: GGRank? = (casualties.count-1 >= row && casualties[row].count-1 >= column) ?
                            casualties[row][column] : nil
                        let boardPosition = GGBoardPosition(row: row,
                                                            column: column,
                                                            player: player,
                                                            rank: rank)

                        BoardSquareView(boardPosition: boardPosition,
                                        draggedPosition: .constant(nil),
                                        dropDelegate: nil,
                                        revealUnit: true,
                                        color: GGConstants.gameViewCasualtySquareColor,
                                        width: squareWidth,
                                        height: squareHeight/2)
                    }
                }
            }
        }
    }
}

#Preview {
    GameView(gameType: .humanVsAI,
             player2Positions: GameViewModel.createStandardDeployment())
}
