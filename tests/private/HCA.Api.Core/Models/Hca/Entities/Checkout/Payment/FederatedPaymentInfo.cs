﻿namespace HCA.Api.Core.Models.Hca.Entities.Checkout.Payment
{
    public class FederatedPaymentInfo
    {
        public string CardToken { get; set; }

        public string PartyId { get; set; }

        public string PaymentMethodId { get; set; }
    }
}