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

import { call, put, select, takeEvery, takeLatest } from 'redux-saga/effects';

import { VoidResult } from 'Foundation/Base/dataModel.Generated';
import { User } from 'Foundation/Commerce';
import { Action, Result } from 'Foundation/Integration';
import { ChangeRoute } from 'Foundation/ReactJss/SitecoreContext';

import * as AuthenticationApi from '../api/Authentication';

import * as actions from './actions';
import { sagaActionTypes } from './constants';
import { AuthenticationPayload, LogoutPayload } from './models';
import * as selectors from './selectors';

import ReactGA from 'react-ga';

export function* authentication(action: Action<AuthenticationPayload>) {
  const { payload } = action;
  const { email, password, returnUrl } = payload;
  if (!email && !password) {
    return;
  }

  yield put(actions.AuthenticationRequest());

  const { error }: Result<VoidResult> = yield call(AuthenticationApi.authentication, email, password);

  if (error) {
    return yield put(actions.AuthenticationFailure());
  }
  ReactGA.event({
    action: 'Login',
    category: 'Authentification'
  });

  yield put(ChangeRoute(returnUrl || '/'));
  yield put(actions.AuthenticationSuccess());
}

export function* initAuthentication() {
  const commerceUser: User = yield select(selectors.commerceUser);

  yield put(actions.SetAuthenticated(!!commerceUser && !!commerceUser.contactId));
}

export function* logout(action: Action<LogoutPayload>) {
  const { returnUrl } = action.payload;

  yield put(actions.LogoutRequest());

  const { error }: Result<VoidResult> = yield call(AuthenticationApi.logout);

  if (error) {
    return yield put(actions.LogoutFailure());
  }
  ReactGA.event({
    action: 'Logout',
    category: 'Authentification'
  });

  yield put(ChangeRoute(returnUrl || '/'));
  yield put(actions.LogoutSuccess());
}

export function* resetState() {
  yield put(actions.ResetAuthenticationProcessState());
}

function* watch() {
  yield takeEvery(sagaActionTypes.AUTHENTICATION, authentication);
  yield takeLatest(sagaActionTypes.INIT_AUTHENTICATION, initAuthentication);
  yield takeEvery(sagaActionTypes.LOGOUT, logout);
  yield takeEvery(sagaActionTypes.RESET_STATE, resetState);
}

export default [watch()];
