﻿using System.Collections.Generic;
using System.Net;
using AutoTests.HCA.Core.API.Models.Hca.Entities.Account;
using AutoTests.HCA.Core.API.Models.Hca.Entities.Account.Authentication;
using AutoTests.HCA.Core.API.Models.Hca.Entities.Addresses;
using AutoTests.HCA.Core.API.Models.Hca.Entities.Billing;
using AutoTests.HCA.Core.API.Models.Hca.Entities.Cart;
using AutoTests.HCA.Core.API.Models.Hca.Entities.Checkout.Delivery;
using AutoTests.HCA.Core.API.Models.Hca.Entities.Checkout.Payment;
using AutoTests.HCA.Core.API.Models.Hca.Entities.Checkout.Shipping;
using AutoTests.HCA.Core.API.Models.Hca.Entities.Order;
using AutoTests.HCA.Core.API.Models.Hca.Entities.Search;
using AutoTests.HCA.Core.API.Models.Hca.RequestResult;

namespace AutoTests.HCA.Core.API.Services.HcaService
{
    public interface IHcaApiService
    {
        HcaResponse<LoginResult> Login(LoginRequest loginData, string endpoint = "auth/login");

        HcaVoidResponse Logout(string endpoint = "auth/logout");

        HcaVoidResponse ChangePassword(ChangePasswordRequest password, string endpoint = "accounts/password");

        HcaResponse<ValidateEmailResult> ValidateEmail(ValidateEmailRequest email, string endpoint = "/accounts/validate");

        HcaResponse<UserResult> CreateUserAccount(CreateAccountRequest newUser, string endpoint = "accounts/account");

        HcaVoidResponse UpdateAccount(UpdateAccountRequest newAddress, string endpoint = "accounts/account");

        HcaResponse<IEnumerable<Address>> GetAddresses(string endpoint = "accounts/address");

        HcaResponse<IEnumerable<Address>> AddAddress(Address newAddress, string endpoint = "accounts/address");

        HcaResponse<IEnumerable<Address>> RemoveAddress(string externalId, string endpoint = "accounts/address");

        HcaResponse<IEnumerable<Address>> UpdateAddress(Address newAddress, string endpoint = "accounts/address");

        HcaResponse<ProductSearchResult> SearchProducts(ProductSearchOptionsRequest product,
            string endpoint = "search/products");

        HcaResponse<CartResult> AddCartLines(CartLinesRequest cartLine, string endpoint = "carts/cartLines");

        HcaResponse<CartResult> UpdateCartLines(CartLinesRequest cartLine, string endpoint = "carts/cartLines");

        HcaResponse<CartResult> GetCart(string endpoint = "carts/cart");

        HcaResponse<CartResult> RemoveCartLine(string productId, string variantId, string endpoint = "carts/cartLines");

        HcaResponse<CartResult> AddPromoCode(PromoCodeRequest promoCode, string endpoint = "carts/promoCodes");

        HcaResponse<DeliveryInfoResult> GetDeliveryInfo(string endpoint = "checkout/deliveryInfo");

        HcaResponse<ShippingInfoResult> GetShippingInfo(string endpoint = "checkout/shippingInfo");

        HcaResponse<BillingInfoResult> GetBillingInfo(string endpoint = "checkout/billingInfo");

        HcaVoidResponse SetShippingOptions(SetShippingOptionsRequest shippingOptions,
            string endpoint = "checkout/shippingOptions");

        HcaVoidResponse SetPaymentInfo(SetPaymentInfoRequest paymentInfo, string endpoint = "checkout/paymentInfo");

        HcaResponse<OrderConfirmationResult> SubmitOrder(string endpoint = "checkout/orders");

        HcaResponse<OrderResult> GetOrder(string trackingNumber, string endpoint = "orders");

        CookieCollection GetClientCookies();
    }
}