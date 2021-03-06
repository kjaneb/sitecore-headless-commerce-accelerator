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

import { Placeholder } from '@sitecore-jss/sitecore-jss-react';

import { HeaderContentProps, HeaderContentState } from './models';

import './styles.scss';

class HeaderContentComponent extends JSS.SafePureComponent<HeaderContentProps, HeaderContentState> {
  protected safeRender() {
    return (
      <div className="header_container">
        <div className={'header_content ' + this.props.params.firstColumnClass}>
          <Placeholder name="navigation-content" rendering={this.props.rendering} />
        </div>
      </div>
    );
  }
}

export const HeaderContent = JSS.rendering(HeaderContentComponent);
