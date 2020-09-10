//    Copyright 2020 EPAM Systems, Inc.
//
//    Licensed under the Apache License, Version 2.0 (the "License");
//    you may not use this file except in compliance with the License.
//    You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//    Unless required by applicable law or agreed to in writing, software
//    distributed under the License is distributed on an "AS IS" BASIS,
//    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//    See the License for the specific language governing permissions and
//    limitations under the License.

import * as JSS from 'Foundation/ReactJss';
import * as React from 'react';

import { NavigationLink } from 'Foundation/UI';
import { WishlistItemProps, WishlistItemState } from './models';

import './styles.scss';

export class WishlistItemComponent extends JSS.SafePureComponent<WishlistItemProps, WishlistItemState> {
  protected safeRender() {
    const { item } = this.props;

    return (
      <tr className="wishlist_content_row">
        <td className="wishlist_product-thumbnail wishlist_table_data">
          <NavigationLink to={`/product/${item.productId}`}>
            <img src={item.imageUrls[0]} alt="" />
          </NavigationLink>
        </td>
        <td className="wishlist_table_data">
          <NavigationLink className="wishlist_item_name" to={`/product/${item.productId}`}>
            {item.displayName}
          </NavigationLink>
        </td>
        <td className="wishlist_table_data">{item.currencySymbol}{item.listPrice}</td>
        <td className="wishlist_table_data">
          <button
            className="wishlist_item_add-btn wishlist_item_button"
            onClick={(e) => this.props.AddToCart({ productId: item.productId, variantId: item.variantId, quantity: 1 })}
          >
            Select Option
          </button>
        </td>
        <td className="wishlist_table_data">
          <button className="wishlist_item_remove-btn wishlist_item_button" onClick={(e) => this.props.RemoveWishlistItem(item.variantId)}>
            <i className="fa fa-times"/>
          </button>
        </td>
      </tr>
    );
  }
}
