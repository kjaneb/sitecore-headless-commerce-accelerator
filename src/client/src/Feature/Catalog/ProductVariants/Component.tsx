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

import * as React from 'react';

import * as JSS from 'Foundation/ReactJss';

import { resolveColor } from 'Foundation/Commerce';
import { Variant } from 'Foundation/Commerce/dataModel.Generated';
import { ProductVariantsProps, ProductVariantsState } from './models';

export default class ProductVariantsComponent extends JSS.SafePureComponent<
  ProductVariantsProps,
  ProductVariantsState
> {
  constructor(props: ProductVariantsProps) {
    super(props);
    this.state = {
      firstVariantClassname: 'colors-option-2-first-load',
    };
  }

  public componentDidMount() {
    const { productId, variants, SelectColorVariant } = this.props;

    if (variants && variants.length > 0) {
      SelectColorVariant(productId, variants[0]);
    }
  }

  protected handleClick(e: React.MouseEvent<HTMLButtonElement>) {
    const listOfColours = document.getElementsByClassName('color-variant-button');
    for (const variants of listOfColours as any) {
      variants.classList.remove('color-variant-button-active');
    }
    e.currentTarget.classList.add('color-variant-button-active');
  }

  protected safeRender() {
    const { variants, sitecoreContext } = this.props;
    const { firstVariantClassname } = this.state;
    return (
      <>
        {variants && variants.length > 1 && (
          <div className="colors-selector">
            <p className="colors-label">Color</p>
            <ul className="colors-list">
              {variants &&
                variants.map((variant, variantIndex) => {
                  const colorName = variant.properties['Color'];
                  const colorValue = resolveColor(colorName, sitecoreContext.productColors);
                  return (
                    <li
                      key={variantIndex}
                      className={`colors-listitem ${firstVariantClassname.includes('first-load') && 'first-load'}`}
                    >
                      <button
                        style={{ background: colorValue }}
                        onClick={(e) => {
                          this.variantSelected(e, variant);
                          this.handleClick(e);
                        }}
                        className={`color-variant-button
                          ${variantIndex === 0 ? firstVariantClassname : 'colors-option-2'}
                        `}
                      />
                    </li>
                  );
                })}
            </ul>
          </div>
        )}
      </>
    );
  }

  private variantSelected(e: React.MouseEvent<HTMLSpanElement>, variant: Variant) {
    const { productId } = this.props;
    this.setState({
      firstVariantClassname: 'colors-option-2',
    });
    this.props.SelectColorVariant(productId, variant);
  }
}
