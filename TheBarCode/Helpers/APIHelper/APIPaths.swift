//
//  APIPaths.swift
//  TheBarCode
//
//  Created by Mac OS X on 10/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit


let apiPathAuthenticate = "auth/login"
let apiPathRegister = "auth/register"
let apiPathRefreshToken = ""
let apiPathSocialLogin = "social/login"
let apiPathMobileLogin = "auth/verify-number"

let apiPathMobileVerification = "auth/activate-number"
let apiPathResentMobileVerification = "user/resend-activation-code"

let apiPathEmailVerification = "user/customer-activate"
let apiPathResendVerificationEmail = "user/resend-activation-email"
let apiPathForgotPassword = "auth/password/email"
let apiPathUserProfileUpdate = "user"

let apiPathReferral = "user/update-referral-code"

let apiPathFiveADayDeals = "five-a-day"

let apiPathCategories = "interest"
let apiPathUpdateSelectedCategories = "userinterest/update-user-interest"

let apiPathInviteViaEmail = "send-invite"
let apiPathLocationUpdate = "user/update-location"

let apiEstablishment = "establishment"

let apiOfferRedeem = "offer-redeem"
let apioffer = "offer"
let apiFavorite = "user-favorite-establishment"

let apiUpdateFavorite = "user-favorite-establishment/update"

let apiPathReloadStatus = "subscription/detail"

let apiPathReload = "subscription"

let apiPathView = "view"

let apiPathGetBarDetail = "establishment"

let apiPathSharedOffers = "share"
let apiPathSharedEvents = "event-share"

let apiPathStandardOffers = "standard-offer-tier"

let apiPathVersionCheck = "version"

let apiPathEvents = "establishment-event"
let apiPathMenu = "establishment-menu"

let apiPathMenuSegments = "establishment-segment"

let apiPathInfluencer = "influencer-counter"
let apiPathSearchAll = "search/all"

let apiPathBookmarkedOffers = "user-favorite-offer"
let apiPathAddRemoveBookmarkedOffer = "user-favorite-offer/update"

let apiPathBookmarkedEvents = "user-bookmark-event"
let apiPathAddRemoveBookmarkedEvents = "user-bookmark-event/update"

let apiPathEstablishmentSubscription = "establishment-subscription"

let apiPathAppShared = "app-shared"

let apiPathUserNotification = "user-notification"

let apiPathNotificationCount = "user-not-read-notification"

let apiPathGetCartQuantity = "cart-count"

let apiPathCart = "cart"
let apiPathOrders = "order"

let apiPathCard = "card"

let apiPathAddresses = "address"

let apiPathOrderOffers = "offers/detail"
let apiPathOrderVouchers = "voucher/detail"

let apiPathPayment = "payment"
let apiPathUpdatePayment = "update-payment"

let apiPathModifierGroups = "modifier-group"

let worldPayTermBaseUrl = "https://online.worldpay.com/3dsr/"
let worldPayScheme = "worldpay-scheme"

let apiPathPaymentSense = "payment-sense"

//Analytics Events
let appLaunched = "App Launched".getFormattedEventName()

let signUpFacebookClick = "Clicked on Sign up with Facebook".getFormattedEventName()
let signUpMobileClick = "Clicked on Sign up with Mobile".getFormattedEventName()
let signUpEmailClick = "Clicked on Sign up with Email".getFormattedEventName()

let signInFacebookClick = "Clicked on Sign in with Facebook".getFormattedEventName()
let signInMobileClick = "Clicked on Sign in with Mobile".getFormattedEventName()
let signInEmailClick = "Clicked on Sign in with Email".getFormattedEventName()

let createAccountViaInstagram = "Create account via Instagram".getFormattedEventName()
let createAccountViaFacebook = "Create account via Facebook".getFormattedEventName()
let createAccountViaApple = "Create account via Apple".getFormattedEventName()
let createAccountViaEmail = "Create account via Email".getFormattedEventName()
let createAccountViaMobile = "Create account via Mobile".getFormattedEventName()

let forgotPasswordRequest = "Clicked on password reset".getFormattedEventName()

//MORE
let signOutClick = "Clicked on sign out".getFormattedEventName()
let privacyPolicyClick = "Clicked on Prviacy Policy".getFormattedEventName()
let paymentSenseTermsAndConditionsClick = "Clicked on Payment Sense Terms And Conditions".getFormattedEventName()
let faqMenuClick = "Clicked on FAQ".getFormattedEventName()
let preferencesSubmitClick = "Submit Preferences".getFormattedEventName()
let reloadButtonClick = "Clicked on Reload button".getFormattedEventName()
let accountSettingsClick = "Clicked on Account settings".getFormattedEventName()
let myAddressesClick = "Clicked on My Addresses".getFormattedEventName()
let myCardsClick = "Clicked on My Cards".getFormattedEventName()
let notificationSettingsClick = "Clicked on Notification settings".getFormattedEventName()
let preferencesMenuClick = "Clicked on Preferences".getFormattedEventName()
let reloadMenuClick = "Clicked on Reload".getFormattedEventName()
let shareOffersMenuClick = "Clicked on Shared offers".getFormattedEventName()
let redemptionReloadRulesMenuClick = "Clicked on redemption and reload rules".getFormattedEventName()
let notificationMenuClick =  "Clicked on Notifications".getFormattedEventName()
let offerWalletClick = "Clicked on Offer Wallet".getFormattedEventName()
let inviteMenuClick = "Clicked on Invite".getFormattedEventName()
let myReservationMenuClick = "Clicked on My Reservations".getFormattedEventName()
let splitPaymentMenuClick = "Clicked on Split Payment".getFormattedEventName()

let updateAccountSettings = "Clicked on update account settings".getFormattedEventName()

let submitBartenderCode = "Submit bartender code".getFormattedEventName()
let bartenderReadyClick = "Clicked on bartender ready".getFormattedEventName()
let redeemOfferButtonClick = "Clicked on redeem offer".getFormattedEventName()

let markABarAsFavorite = "Mark a bar as favorite".getFormattedEventName()
let locationMapClick = "Clicked on bar location map".getFormattedEventName()

let shareDealFromShareScreenClick = "Clicked on share button from share screen"

//Explore
let barClickFromExplore = "Clicked on a bar on Explore screen".getFormattedEventName()
let bannerClick = "Clicked on banner".getFormattedEventName()
let savingsClick = "Clicked on savings".getFormattedEventName()
let creditsClick = "Clicked on credits".getFormattedEventName()
let barTabClickFromExplore = "Clicked on bars tab from explore".getFormattedEventName()
let dealTabClickFromExplore = "Clicked on deals tab from explore".getFormattedEventName()
let liveOffersTabClickFromExplore = "Clicked on live offers tab from explore".getFormattedEventName()
let preferenceFilterClick = "Clicked on preference filter".getFormattedEventName()
let standardOfferFilterClick = "Clicked on standard offer filter".getFormattedEventName()
let barDetailAboutClick = "Clicked on About tab on Bar Detail".getFormattedEventName()
let barDetailDealClick = "Clicked on Deals tab on Bar Detail".getFormattedEventName()
let barDetailLiveOffersClick = "Clicked on Live offers tab on Bar Detail".getFormattedEventName()

//FiveADay
let fiveADayShareClick = "Clicked on share Five a day offer".getFormattedEventName()
let barDetailFromFiveADayClick = "Clicked on bar detail from Five a day".getFormattedEventName()
let offerDetailFromFiveADayClick = "Clicked on Five a day offer detail".getFormattedEventName()

//Invite
let inviteFriendsClick = "Clicked on Invite Friends button".getFormattedEventName()
let shareWithContactsClick = "Clicked on Share with Contacts button".getFormattedEventName()

//TabBAr
let fiveADayTabClick = "Clicked on Five a day menu icon".getFormattedEventName()
let favouriteTabClick = "Clicked on Favourite menu icon".getFormattedEventName()
let moreTabClick = "Clicked on more menu icon".getFormattedEventName()
let exploreTabClick = "Clicked on Explore in menu tab".getFormattedEventName()
let inviteTabClick = "Clicked on Invite menu icon".getFormattedEventName()

//Screen View Events
let viewExploreScreen = "Viewed explore screen".getFormattedEventName()
let viewBarDetailsScreen = "Viewed bar details".getFormattedEventName()
let viewFiveADayScreen = "Viewed Five a day screen".getFormattedEventName()
let viewSharedOfferScreen = "Viewed shared offer list".getFormattedEventName()
let viewSharedEventScreen = "Viewed shared event list".getFormattedEventName()
let viewAccountSettingScreen = "Viewed account settings screen".getFormattedEventName()
let viewNotificationSettingScreen = "Viewed notification settings screen".getFormattedEventName()
let viewPreferencesScreen = "Viewed preferences".getFormattedEventName()
let viewReloadScreen = "Viewed reload screen".getFormattedEventName()
let viewFaqsScreen = "Viewed faqs screen".getFormattedEventName()
let viewRedemptionRulesScreen = "Viewed redemption reload rules screen".getFormattedEventName()
//"Viewed redemption and reload rules screen".getFormattedEventName()
let viewPrivacyPolicyScreen = "Viewed privacy policy screen".getFormattedEventName()
let viewFavouriteScreen = "Viewed favourites screen".getFormattedEventName()


//Notifications
let notificationClickFromNotifications = "Clicked on a notification on Notification screen".getFormattedEventName()

