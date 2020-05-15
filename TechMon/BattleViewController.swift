//
//  BattleViewController.swift
//  TechMon
//
//  Created by 松島優希 on 2020/05/15.
//  Copyright © 2020 松島優希. All rights reserved.
//

import UIKit

class BattleViewController: UIViewController {
    
    @IBOutlet var playerNameLabel: UILabel!
    @IBOutlet var playerImageView: UIImageView!
    @IBOutlet var playerHPLabel: UILabel!
    @IBOutlet var playerMPLabel: UILabel!
    @IBOutlet var playerTPLabel: UILabel!
    
    @IBOutlet var enemyNameLabel: UILabel!
    @IBOutlet var enemyImageView: UIImageView!
    @IBOutlet var enemyHPLabel: UILabel!
    @IBOutlet var enemyMPLabel: UILabel!
    
    let techMonManager = TechMonManager.shared
    
    var playerHP = 100
    var playerMP = 0
    var enemyHP = 200
    var enemyMP = 0
    
    var player: Character!
    var enemy: Character!
    var gameTimer: Timer!
    var isPlayerAttackAvailable: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        player = techMonManager.player
        enemy = techMonManager.enemy
        
        playerNameLabel.text = "金色の勇者"
        playerImageView.image = UIImage(named: "monster010.png")
        playerHPLabel.text = "\(playerHP)/ 100"
        playerMPLabel.text = "\(playerMP)/ 20"
        
        enemyNameLabel.text = "龍"
        enemyImageView.image = UIImage(named: "monster.png")
        enemyHPLabel.text = "\(enemyHP) / 200"
        enemyMPLabel.text = "\(enemyMP) / 35"
        
        gameTimer = Timer.scheduledTimer (
            timeInterval: 0.1,
            target: self,
            selector: #selector(updateGame),
            userInfo: nil,
            repeats: true
            )
        gameTimer.fire()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        techMonManager.playBGM(fileName: "BGM_battle001")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        techMonManager.stopBGM()
    }
    
    @objc func updateGame() {
        playerMP += 1
        if playerMP >= 20 {
            isPlayerAttackAvailable = true
            playerMP = 20
        }else{
            isPlayerAttackAvailable = false
        }
        
        enemyMP += 1
        if enemyMP >= 35 {
            enemyAttack()
            enemyMP = 0
        }
        updateUI()

            }
    
    func enemyAttack(){
        techMonManager.damageAnimation(imageView: playerImageView)
        techMonManager.playSE(fileName: "SE_attack")
        
        player.currentHP -= 20
        
        playerHPLabel.text = "\(player.currentHP) / 100"
        
        if player.currentHP <= 0 {
            finishBattle(vanishImageView: playerImageView, isPlayerWin: false)
        }
    }
    
    func finishBattle(vanishImageView: UIImageView, isPlayerWin: Bool){
        techMonManager.vanishAnimation(imageView: vanishImageView)
        techMonManager.stopBGM()
        gameTimer.invalidate()
        resetStatus()
        isPlayerAttackAvailable = false
        
        var finishMessage: String = ""
        if isPlayerWin {
            techMonManager.playSE(fileName: "SE_fanfare")
            finishMessage = "勇者の勝利!!"
        }else{
            techMonManager.playSE(fileName: "SE_gameover")
            finishMessage = "勇者の敗北..."
        }
        
        let alert = UIAlertController(title: "バトル終了", message: finishMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in self.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
        resetStatus()
    }
    
    @IBAction func attackAction(){
        if isPlayerAttackAvailable {
            techMonManager.damageAnimation(imageView: enemyImageView)
            techMonManager.playSE(fileName: "SE_attack")
            
            enemy.currentHP -= player.attackPoint
            updateUI()
            
            player.currentTP += 10
            if player.currentTP >= player.maxTP{
                player.currentTP = player.maxTP
            }
            playerMP = 0
            judgeBattle()

        }
    }
    
    @IBAction func tameruAction(){
        if isPlayerAttackAvailable {
            techMonManager.playSE(fileName: "SE_charge")
            player.currentTP += 40
            if player.currentTP >= player.maxTP {
                player.currentTP = player.maxTP
            }
            playerMP = 0
        }
    }
    
    @IBAction func fireAction() {
        if isPlayerAttackAvailable && player.currentTP >= 40 {
            
            techMonManager.damageAnimation(imageView: enemyImageView)
            techMonManager.playSE(fileName: "SE_fire")
            
            enemy.currentHP -= 100
            
            player.currentTP -= 40
            if player.currentTP <= 0 {
                
                player.currentTP = 0
            }
            playerMP = 0
            
            judgeBattle()
        }
    }
    
    func updateUI() {
        playerHPLabel.text = "\(player.currentHP) / \(player.maxHP)"
        playerMPLabel.text = "\(playerMP) / \(player.maxMP)"
        playerTPLabel.text = "\(player.currentTP) / \(player.maxTP)"
        
        enemyHPLabel.text = "\(enemy.currentHP) / \(enemy.maxHP)"
        enemyMPLabel.text = "\(enemyMP) / \(enemy.maxMP)"
    }
    
    func judgeBattle() {
        if player.currentHP <= 0 {
            finishBattle(vanishImageView: playerImageView, isPlayerWin: false)
        }else if enemy.currentHP <= 0 {
            finishBattle(vanishImageView: enemyImageView, isPlayerWin: true)
        }
    }
    
    func resetStatus() {
        
        player.resetStatus()
        enemy.resetStatus()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
