//
//  Factory.swift
//  CashFlow
//
//  Created by Alex de la Fuente Martín on 20/6/24.
//

import UIKit

class Factory: NSObject {
    
    // MARK: - Sign In, Register and Forgot Password Screens
    static func provideNavigationController(storyboard: UIStoryboard) -> UINavigationController{
        let navigationController = storyboard.instantiateViewController(withIdentifier: Screens.navigationController) as! UINavigationController
        return navigationController
    }
    
    
    static func provideRegisterScreen(storyboard: UIStoryboard) -> RegisterViewController{
        let registerVC = storyboard.instantiateViewController(withIdentifier: Screens.registerScreen) as! RegisterViewController
        return registerVC
    }
    
    
    static func provideForgotPasswordScreen(storyboard: UIStoryboard) -> ForgotPasswordViewController{
        let forgotPasswordVC = storyboard.instantiateViewController(withIdentifier: Screens.forgotPasswordScreen) as! ForgotPasswordViewController
        return forgotPasswordVC
    }
    
    
    static func provideTabBarController(storyboard: UIStoryboard) -> UITabBarController{
        let tabBarController = storyboard.instantiateViewController(withIdentifier: Screens.tabBarController) as! UITabBarController
        return tabBarController
    }
    
    
    // static func provideHomeScreen(storyboard: UIStoryboard) -> HomeViewController{
    //     let homeVC = storyboard.instantiateViewController(withIdentifier: Screens.homeScreen) as! HomeViewController
    //     return homeVC
    // }
    
    //MARK: - Home and Account Screens
    static func providePersonalInfoScreen(storyboard: UIStoryboard) -> PersonalInfoTableViewController{
        let personalInfoScreen = storyboard.instantiateViewController(withIdentifier: Screens.personalInfoScreen) as! PersonalInfoTableViewController
        return personalInfoScreen
    }
    
    
    static func provideChangeCurrencyScreen() -> ChangeCurrencyViewController{
        let changeCurrencyScreen = ChangeCurrencyViewController(nibName: Screens.changeCurrencyScreen, bundle: nil)
        return changeCurrencyScreen
    }
    
    
    static func provideChangePasswordScreen(storyboard: UIStoryboard) -> ChangePasswordViewController{
        let changePasswordScreen = storyboard.instantiateViewController(withIdentifier: Screens.changePasswordScreen) as! ChangePasswordViewController
        return changePasswordScreen
    }
    
    
    static func provideAllTransactionsScreen(storyboard: UIStoryboard) -> AllTransactionsTableViewController{
        let allTransactionsScreen = storyboard.instantiateViewController(withIdentifier: Screens.allTransactionsScreen) as! AllTransactionsTableViewController
        return allTransactionsScreen
    }
    
    
    static func provideDateRangeFilter() -> DateRangeFilterViewController{
        let dateRangeFilterScreen = DateRangeFilterViewController(nibName: Screens.dateRangeFilterScreen, bundle: nil)
        return dateRangeFilterScreen
    }
    
    
    static func provideAddTransactionScreen(storyboard: UIStoryboard) -> AddTransactionViewController{
        let addTransactionScreen = storyboard.instantiateViewController(withIdentifier: Screens.addTransactionScreen) as! AddTransactionViewController
        return addTransactionScreen
    }
    
    
    static func provideTransactionDetailScreen(storyboard: UIStoryboard, transaction: Transaction) -> TransactionDetailViewController{
        let transactionDetailScreen = storyboard.instantiateViewController(withIdentifier: Screens.transactionDetailScreen) as! TransactionDetailViewController
        transactionDetailScreen.transaction = transaction
        return transactionDetailScreen
    }
    
    
    static func provideEditTransactionScreen(storyboard: UIStoryboard) -> EditTransactionViewController{
        let editTransactionScreen = storyboard.instantiateViewController(withIdentifier: Screens.editTransactionScreen) as! EditTransactionViewController
        return editTransactionScreen
    }
    
    
    static func provideBalanceDetailScreen(storyboard: UIStoryboard) -> BalanceDetailViewController{
        let balanceDetailScreen = storyboard.instantiateViewController(withIdentifier: Screens.balanceDetailScreen) as! BalanceDetailViewController
        return balanceDetailScreen
    }
    
    
    static func provideTotalMonthlyExpensesScreen(storyboard: UIStoryboard) -> MonthlyExpensesViewController{
        let monthlyExpensesScreen = storyboard.instantiateViewController(withIdentifier: Screens.monthlyExpensesScreen) as! MonthlyExpensesViewController
        return monthlyExpensesScreen
    }
    
    
    static func providetotalBalanceChartScreen(storyboard: UIStoryboard, dataType: LinearChartDataType) -> BalanceChartViewController{
        let balanceChartScreen = storyboard.instantiateViewController(withIdentifier: Screens.balanceChartScreen) as! BalanceChartViewController
        balanceChartScreen.dataType = dataType
        return balanceChartScreen
    }
    
    
    static func provideChangeCategoryScreen() -> ChangeCategoryViewController{
        let changeCategoryScreen = ChangeCategoryViewController(nibName: Screens.changeCategoryScreen, bundle: nil)
        return changeCategoryScreen
    }
    
    
    static func provideCategoryFiltersSelectionScreen() -> CategoryFiltersSelectionViewController{
        let categoryFiltersSelectionScreen = CategoryFiltersSelectionViewController(nibName: Screens.categoryFiltersSelectionScreen, bundle: nil)
        return categoryFiltersSelectionScreen
    }
    
    
    static func providePrivacyPolicyScreen(storyboard: UIStoryboard) -> PrivacyPolicyViewController{
        let privacyPolicyScreen = storyboard.instantiateViewController(withIdentifier: Screens.privacyPolicyScreen) as! PrivacyPolicyViewController
        return privacyPolicyScreen
    }
    
    
    static func provideHelpScreen(storyboard: UIStoryboard) -> HelpViewController{
        let helpScreen = storyboard.instantiateViewController(withIdentifier: Screens.helpScreen) as! HelpViewController
        return helpScreen
    }
    
    
}

