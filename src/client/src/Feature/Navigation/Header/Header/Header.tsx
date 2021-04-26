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

import { Placeholder } from '@sitecore-jss/sitecore-jss-react';
import classnames from 'classnames';
import React, { FC, useCallback, useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';

import { BaseDataSourceItem, BaseRenderingParam, RenderingWithParams } from 'Foundation/ReactJss';

import { closeHamburgerMenu, selectHamburgerMenuVisibility } from '../NavigationMenu/Integration';

import './Header.scss';

const HEADER_TOP = 0;

export const Header: FC<RenderingWithParams<BaseDataSourceItem, BaseRenderingParam>> = ({ rendering }) => {
  const dispatch = useDispatch();

  const isHamburgerMenuVisible = useSelector(selectHamburgerMenuVisibility);

  const [scroll, setScroll] = useState<number>(0);

  const handleScroll = () => {
    setScroll(document.documentElement.scrollTop);
  };

  const handleHamburgerMenuClose = useCallback(() => {
    dispatch(closeHamburgerMenu());
  }, [dispatch]);

  useEffect(() => {
    document.addEventListener('scroll', handleScroll);

    return () => {
      document.removeEventListener('scroll', handleScroll);
    };
  }, []);

  return (
    <>
      <header
        className={classnames('header', {
          'header--active': isHamburgerMenuVisible,
          'header--inactive': !isHamburgerMenuVisible,
          'header--sticky': scroll > HEADER_TOP,
        })}
        data-el="header"
      >
        <div className="header-desktop">
          <Placeholder name="header-content" rendering={rendering} />
        </div>

        <div className={classnames('header_mobile mobile-menu')}>
          <button className="mobile-menu_close" onClick={handleHamburgerMenuClose}>
            <i className="pe-7s-close" />
          </button>
          <div className="mobile-menu_container">
            <div className="mobile-menu_content">
              <Placeholder name="header-content" rendering={rendering} />
            </div>
          </div>
        </div>
      </header>
      <Placeholder name="breadcrumb" rendering={rendering} />
    </>
  );
};