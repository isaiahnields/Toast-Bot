//
//  ToastCardStack.swift
//  Toast Bot
//
//  Created by isaiahnields on 7/7/20.
//  Copyright © 2020 com.isaiahnields. All rights reserved.
//

import UIKit



class ToastCardStack: UIView {
    
    var model: Model!
    
    @IBOutlet var toastCountLabel: UILabel!
    @IBOutlet var cardOne: UIView!
    @IBOutlet var cardOneLabel: UILabel!
    @IBOutlet var cardTwo: UIView!
    @IBOutlet var cardTwoLabel: UILabel!
    
    func setUp(model: Model) {
        self.model = model
        self.model.nextToastIndex = 1
        
        self.toastCountLabel.text = "\(self.model.nextToastIndex)"
        self.toastCountLabel.clipsToBounds = true
        self.toastCountLabel.isHidden = false
        
        self.cardOne.center = CGPoint(x: self.frame.width / 2, y: self.cardOne.center.y)
        self.cardTwo.center = CGPoint(x: self.frame.width / 2, y: self.cardTwo.center.y)
        
        self.setCardStyle(card: cardOne, cardType: .normal)
        self.setCardStyle(card: cardTwo, cardType: .normal)
        
        self.addCardShadow(card: cardOne)
        self.addCardShadow(card: cardTwo)
        
        let toasts = model.faceObservations[self.model.observationIndex].toasts!
        self.cardOneLabel.text = toasts[self.model.nextToastIndex - 1].body
        self.cardTwoLabel.text = toasts[self.model.nextToastIndex].body
    }
    
    @IBAction func onCardOnePan(_ sender: UIPanGestureRecognizer) {
        onCardPan(sender)
    }
    
    @IBAction func onCardTwoPan(_ sender: UIPanGestureRecognizer) {
        onCardPan(sender)
    }
    
    func onCardPan(_ sender: UIPanGestureRecognizer) {
        let card = sender.view!
        let translation = sender.translation(in: self)
        let velocity = sender.velocity(in: self)
        
        switch sender.state {
            case .began, .changed:
                card.center = CGPoint(x: card.center.x + translation.x, y: card.center.y)
                sender.setTranslation(CGPoint.zero, in: self)
            case .ended:
                let outOfBounds = abs(card.center.x - self.frame.width / 2) > self.frame.width / 3
                let goingFast = abs(velocity.x) > 1000
                if outOfBounds || goingFast {
                    let direction = card.center.x - self.frame.width / 2 > 0 ? Direction.right: Direction.left
                    swipeAway(card: card, direction: direction, duration: 0.25)
                    reset(card: card, direction: direction, delay: 0.275)
                }
                else {
                    UIView.animate(withDuration: 0.25) {
                        card.center = CGPoint(x: self.frame.width / 2, y: card.center.y)
                    }
                }
            default:
                break
        }
    }
    
    func swipeAway(card: UIView, direction: Direction, duration: Double) {
        UIView.animate(withDuration: duration) {
            if direction == Direction.right {
                card.center = CGPoint(x: 2 * self.frame.width, y: card.center.y)
            }
            else if direction == Direction.left {
                card.center = CGPoint(x: -2 * self.frame.width, y: card.center.y)
            }
        }
    }
    
    func reset(card: UIView, direction: Direction, delay: Double) {
        
        func replace() {
            let nextToast = self.getNextToast()
            let cardLabel: UILabel = card == self.cardOne ? self.cardOneLabel: self.cardTwoLabel
            if nextToast.cardType != .none {
                card.isHidden = true
                card.center = CGPoint(x: self.frame.width / 2, y: card.center.y)
                self.sendSubviewToBack(card)
                card.isHidden = false
                card.isUserInteractionEnabled = false
                
                self.setCardStyle(card: card, cardType: nextToast.cardType)
                cardLabel.text = nextToast.text
            }
            else {
                cardLabel.text = nil
            }
            if nextToast.cardType == .upgrade {
                
            }
        }
        
        func next() {
            let nextCard: UIView = card == self.cardOne ? self.cardTwo: self.cardOne
            let nextCardLabel: UILabel = card == self.cardOne ? self.cardTwoLabel: self.cardOneLabel
            nextCard.isUserInteractionEnabled = true
            if nextCardLabel.text != nil {
                if isPremium() {
                    self.toastCountLabel.text = "\(self.model.nextToastIndex)"
                }
                else {
                    if self.model.nextToastIndex == numToasts() + 1 {
                        self.toastCountLabel.isHidden = true
                    }
                    else {
                        self.toastCountLabel.text = "\(self.model.nextToastIndex)"
                    }
                }
            }
            else {
                if !isPremium() && direction == Direction.right {
                    let toastViewController = UIApplication.shared.windows.first?.rootViewController?.presentedViewController as! ToastViewController
                    toastViewController.performSegue(withIdentifier: "showUpgrade", sender: nil)
                }
                self.removeToastCardStack()
                self.addToastCardStack()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.model.nextToastIndex += 1
            replace()
            next()
        }
    }
    
    func isPremium() -> Bool {
        return UserDefaults.standard.bool(forKey: "isaiahnields.ToastBot.Premium")
    }
    
    func numToasts() -> Int {
        if isPremium() {
            return 25
        }
        else {
            return 3
        }
    }
    
    func setFaceObservation(index: Int) {
        self.model.observationIndex = index
        // TODO: implement refresh of toasts
    }
    
    func getNextToast() -> ToastCardInfo {
        let toasts = model.faceObservations[self.model.observationIndex].toasts!
        if isPremium() {
            if self.model.nextToastIndex == numToasts() {
                return ToastCardInfo(text: nil, cardType: .none)
            }
            else {
                return ToastCardInfo(text: toasts[self.model.nextToastIndex].body, cardType: .normal)
            }
        }
        else {
            if self.model.nextToastIndex == numToasts() {
                return ToastCardInfo(text: "🥂 Swipe right to unlock all toasts 🥂", cardType: .upgrade)
            }
            else if self.model.nextToastIndex >= numToasts() + 1 {
                return ToastCardInfo(text: nil, cardType: .none)
            }
            else {
                return ToastCardInfo(text: toasts[self.model.nextToastIndex].body, cardType: .normal)
            }
        }
    }
    
    func setCardStyle(card: UIView, cardType: CardType) {
        let cardLabel: UILabel = card == cardOne ? cardOneLabel: cardTwoLabel
        if cardType == CardType.normal {
            cardLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            cardLabel.numberOfLines = 0
            cardLabel.adjustsFontSizeToFitWidth = false
        }
        else if cardType == CardType.upgrade {
            cardLabel.textColor = #colorLiteral(red: 0.9019607843, green: 0.6862745098, blue: 0.1803921569, alpha: 1)
            cardLabel.numberOfLines = 1
            cardLabel.adjustsFontSizeToFitWidth = true
        }
    }
    
    func addToastCardStack() {
        self.setUp(model: self.model)
        UIView.animate(withDuration: 0.25) {
            self.transform = CGAffineTransform(translationX: 0, y: 0)
        }
    }
    
    func removeToastCardStack() {
        self.transform = CGAffineTransform(translationX: 0, y: 300)
    }
    
    func addCardShadow(card: UIView) {
        card.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        card.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        card.layer.shadowRadius = 2.0
        card.layer.shadowOpacity = 0.25
    }
}

enum Direction {
    case right
    case left
}

enum CardType {
    case normal
    case upgrade
    case none
}

struct ToastCardInfo {
    let text: String?
    let cardType: CardType
}
