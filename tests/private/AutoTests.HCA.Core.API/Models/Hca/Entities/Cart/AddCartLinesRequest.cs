﻿namespace AutoTests.HCA.Core.API.Models.Hca.Entities.Cart
{
    public class CartLinesRequest
    {
        public string ProductId { get; set; }

        public int Quantity { get; set; }

        public string VariantId { get; set; }

        public CartLinesRequest() { }

        public CartLinesRequest(string productId, int quantity, string variantId)
        {
            ProductId = productId;
            Quantity = quantity;
            VariantId = variantId;
        }
    }
}