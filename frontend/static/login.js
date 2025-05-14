//
// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//
import * as gesso from "./gesso/main.js";
import { renderCountryFlag } from './flags.js';
import * as main from "./main.js";

const html = `
<body class="excursion login">
  <section>
    <div>
      <h1>
      <span class="material-icons-outlined"> account_balance </span> Green Bank Portal
      </h1>

      <p>Green Bank Portal is an example application.  It uses a web
      frontend, a relational database, and a payment-processing
      service. The application is distributed across two different clusters on separte countries
      and it a different payments service per country</p>

      <p>You can login as Bank Customer or Bank Employee. Depending on the country the system will display different information
      based on the legislation of each country.</p>

      <div class="hflex">
        <div>
          <h2>Log in as a Customer:</h2>

          <nav id="customer-login-links"></nav>
        </div>

        <div>
          <h2>Log in as a Bank Employee:</h2>

          <nav id="employee-login-links"></nav>
        </div>
      </div>
    </div>
  </section>
</body>
`;

function updatePatientLoginLinks(data) {
    const nav = gesso.createNav(null, "#customer-login-links");

    for (const item of Object.values(data.patients)) {
        const countryCode = item.country || "";
        const displayName = `${item.name} (${renderCountryFlag(countryCode)})`;

        const link = gesso.createLink(nav, `/customer?id=${item.id}`, displayName);

        link.addEventListener("click", () => {
          localStorage.setItem("countryCode", countryCode);
        });
    }

    $("#customer-login-links").replaceWith(nav);
}

function updateDoctorLoginLinks(data) {
    const nav = gesso.createNav(null, "#employee-login-links");

    for (const item of Object.values(data.doctors)) {
        const countryCode = item.country || "";
        const displayName = `${item.name} (${renderCountryFlag(countryCode)})`;

        const link = gesso.createLink(nav, `/employee?id=${item.id}`, displayName);

        link.addEventListener("click", () => {
          localStorage.setItem("countryCode", countryCode);
        });
    }

    $("#employee-login-links").replaceWith(nav);
}

export class MainPage extends gesso.Page {
    constructor(router) {
        super(router, "/", html);
    }

    updateContent() {
        var cc_menu = document.getElementById("country-select");
        gesso.fetchJSON("/api/data/proxy", data => {
            updatePatientLoginLinks(data);
            updateDoctorLoginLinks(data);
        }, null, {"Country-Code": "ES"});
    }
}
