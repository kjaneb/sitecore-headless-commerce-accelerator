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

import { Map } from './Map/Component';
import { Store, StoreLocatorProps, StoreLocatorState } from './models';

import { Marker } from './Marker/models';

import { FORM_FIELDS } from './constants';

import { Form, FormValues, Input, Select, Submit } from 'Foundation/ReactJss/Form';

export class StoreLocatorComponent extends JSS.SafePureComponent<StoreLocatorProps, StoreLocatorState> {
  public componentDidMount() {
    this.props.GetStores();
  }

  protected safeRender() {
    const { stores } = this.props;
    const {
      title,
      description,
      defaultLatitude,
      defaultLongitude,
      countries,
      radiuses,
    } = this.props.fields.data.datasource;

    return (
      <div className="col-md-8 order-md-1">
        <h4 className="mb-3">{title.jss.value}</h4>
        <p>{description.jss.value}</p>
        <Form className="needs-validation">
          <div className="row">
            <div className="col-md-3 mb-3">
              <JSS.Text tag="label" field={{ value: 'Zip Code', editable: 'Zip Code' }} />
              <Input
                type="text"
                className="form-control"
                name={FORM_FIELDS.ZIP_CODE}
                required={true}
                placeholder="Enter zip code..."
              />
            </div>
            <div className="col-md-3 mb-3">
              <JSS.Text field={{ value: 'Country:', editable: 'Country' }} tag="label" className="required" />
              <Select name={FORM_FIELDS.COUNTRY} type="text" required={true}>
                <option value="">Not Selected</option>
                {countries.items.map((country, index) => (
                  <option key={`${index}-${country.code.jss.value}`} value={country.code.jss.value}>
                    {country.title.jss.value}
                  </option>
                ))}
              </Select>
            </div>
            <div className="col-md-3 mb-3">
              <JSS.Text tag="label" field={{ value: 'Radius', editable: 'Radius' }} />
              <Select className="custom-select d-block w-100" name={FORM_FIELDS.RADIUS} type="text" required={true}>
                <option value="">Not Selected</option>
                {radiuses.items.map((radius, index) => (
                  <option key={`${index}-${radius.value.jss.value}`} value={radius.value.jss.value}>
                    {radius.value.jss.value}
                  </option>
                ))}
              </Select>
            </div>
            <div className="col-md-8 mb-3">
              <Submit onSubmitHandler={(formValues) => this.handleFormSubmit(formValues)}>Search</Submit>
            </div>
          </div>
          <div className="row">
            <div className="col-md-10 mb-3">
              <Map
                markers={stores.map(this.mapStoreToMarker)}
                defaultCenter={{ latitude: +defaultLatitude.jss.value, longitude: +defaultLongitude.jss.value }}
                googleMapURL="https://maps.googleapis.com/maps/api/js?key=AIzaSyBA0ZPWHT4Wg_SA3lqx-lb5CG27XG73CYA&v=3.exp&libraries=geometry,drawing,places"
                loadingElement={<div style={{ height: `100%` }} />}
                containerElement={<div style={{ height: `400px` }} />}
                mapElement={<div style={{ height: `100%` }} />}
              />
            </div>
          </div>
        </Form>
      </div>
    );
  }

  private handleFormSubmit(formValues: FormValues) {
    this.props.FindStores(
      formValues[FORM_FIELDS.ZIP_CODE] as string,
      formValues[FORM_FIELDS.COUNTRY] as string,
      formValues[FORM_FIELDS.RADIUS] as number,
    );
  }

  private mapStoreToMarker(store: Store): Marker {
    return {
      information: {
        description: store.description,
        title: store.title,
      },
      position: {
        latitude: +store.latitude,
        longitude: +store.longitude,
      },
    };
  }
}