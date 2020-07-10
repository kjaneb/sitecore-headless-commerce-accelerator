﻿using System;
using System.Collections.Generic;

namespace HCA.Api.Core.Models.Hca.Entities.Search
{
    public class ProductSearchOptionsRequest
    {
        public string SearchKeyword { get; set; }

        public IEnumerable<Facet> Facets { get; set; }

        public Guid CategoryId { get; set; }

        public string SortField { get; set; }

        public SortDirection SortDirection { get; set; }

        public int PageNumber { get; set; }

        public int PageSize { get; set; }
    }
}