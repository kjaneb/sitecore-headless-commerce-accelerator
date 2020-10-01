﻿using System.Linq;
using AutoTests.AutomationFramework.Shared.Helpers;
using AutoTests.HCA.Core.API.HcaApi.Models.Entities.Account.Authentication;
using NUnit.Framework;

namespace AutoTests.HCA.Tests.APITests.Account
{
    [Parallelizable(ParallelScope.None)]
    [TestFixture(Description = "Authorization Tests")]
    public class AuthorizationTests : BaseAccountTest
    {
        [Test(Description = "Checks that an existing user is logged in.")]
        public void T1_POSTLoginRequest_ValidUser_VerifyCookies()
        {
            // Arrange
            var user = new LoginRequest(DefUser.Email, DefUser.Password);

            // Act
            var result = ApiContext.Auth.Login(user);

            // Assert
            result.CheckSuccessfulResponse();
            Assert.Multiple(() =>
            {
                var cookies = ApiContext.Client.GetCookies().FirstOrDefault(x => x.Name == AUTHORIZATION_COOKIE_NAME);
                Assert.NotNull(cookies, "The response of '/login' doesn't contain authorization cookies.");
                Assert.False(string.IsNullOrWhiteSpace(cookies.Value), "Returned cookies contain empty value.");
            });
        }

        [Test(Description = "Checks that the server returns an error if the email is not valid.")]
        public void T2_POSTLoginRequest_InvalidEmail_BadRequest()
        {
            // Arrange
            const string expErrorMsg = "The Email field is not a valid e-mail address.";
            var user = new LoginRequest(StringHelpers.RandomString(2), DefUser.Password);

            // Act
            var result = ApiContext.Auth.Login(user);

            // Assert
            result.CheckUnSuccessfulResponse();
            Assert.Multiple(() =>
            {
                result.VerifyErrors(expErrorMsg);

                var cookies = ApiContext.Client.GetCookies().FirstOrDefault(x => x.Name == AUTHORIZATION_COOKIE_NAME);
                Assert.Null(cookies, "The filed response of '/login' contains authorization cookies.");
            });
        }

        [Test(Description = "Checks that the server returns an error if the email is non-existing.")]
        public void T3_POSTLoginRequest_NonExistingEmail_BadRequest()
        {
            // Arrange
            const string expErrorMsg = "Incorrect login or password.";
            var userLoginRequest = new LoginRequest("12@mail.com", DefUser.Password);

            // Act
            var result = ApiContext.Auth.Login(userLoginRequest);

            // Assert
            result.CheckUnSuccessfulResponse();
            Assert.Multiple(() =>
            {
                result.VerifyErrors(expErrorMsg);

                var cookies = ApiContext.Client.GetCookies().FirstOrDefault(x => x.Name == AUTHORIZATION_COOKIE_NAME);
                Assert.Null(cookies, "The filed response of '/login' contains authorization cookies.");
            });
        }

        [Test(Description = "Checks that the server returns an error if the password is invalid.")]
        public void T4_POSTLoginRequest_InvalidPassword_BadRequest()
        {
            // Arrange
            const string expErrorMsg = "Incorrect login or password.";
            var userLoginRequest = new LoginRequest(DefUser.Email, "0000");

            // Act
            var result = ApiContext.Auth.Login(userLoginRequest);

            // Assert
            result.CheckUnSuccessfulResponse();
            Assert.Multiple(() =>
            {
                result.VerifyErrors(expErrorMsg);

                var cookies = ApiContext.Client.GetCookies().FirstOrDefault(x => x.Name == AUTHORIZATION_COOKIE_NAME);
                Assert.Null(cookies, "The filed response of '/login' contains authorization cookies.");
            });
        }

        [Test(Description = "Checks that the authorized user is logged out.")]
        public void T5_POSTLogoutRequest_VerifyResponse()
        {
            // Arrange
            var user = new LoginRequest(DefUser.Email, DefUser.Password);

            // Act
            ApiContext.Auth.Login(user);
            Assert.NotNull(ApiContext.Client.GetCookies().FirstOrDefault(x => x.Name == AUTHORIZATION_COOKIE_NAME),
                "The response of '/logout' doesn't contain authorization cookies.");
            var logoutResult = ApiContext.Auth.Logout();

            // Assert
            logoutResult.CheckSuccessfulResponse();
            Assert.Multiple(() =>
            {
                logoutResult.VerifyOkResponseData();

                Assert.Null(ApiContext.Client.GetCookies().FirstOrDefault(x => x.Name == AUTHORIZATION_COOKIE_NAME),
                    "The response of '/logout' contains authorization cookies.");
            });
        }
    }
}