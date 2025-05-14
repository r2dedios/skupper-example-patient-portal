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
import * as main from "./main.js";

const createHtml = `
<body class="excursion">
  <section>
    <div>
      <h1>Bill a customer for an appointment</h1>

      <form id="bill-create-form">
        <input type="hidden" id="appointment" name="appointment"/>
        <input type="hidden" id="customer" name="customer"/>
        <input type="hidden" id="employee" name="employee"/>

        <div class="form-field">
          <div>Customer</div>
          <div><input id="customer-name" name="customer-name" readonly="readonly"/></div>
          <div>The customer for this appointment</div>
        </div>

        <div class="form-field">
          <div>Appointment</div>
          <div><input id="appointment-datetime" name="appointment-datetime" readonly="readonly"/></div>
          <div>The date and time of the customer's visit</div>
        </div>

        <div class="form-field">
          <div>Amount due</div>
          <div>
            <input type="number" id="amount-due" name="amount-due" placeholder="0" required="required"/>
          </div>
          <div>The amount to bill the customer</div>
        </div>

        <div class="form-buttons">
          <button type="submit">Bill customer</button>
        </div>
      </form>
    </div>
  </section>
</body>
`;

export class CreatePage extends gesso.Page {
    constructor(router) {
        super(router, "/bill/create", createHtml);

        this.body.$("#bill-create-form").addEventListener("submit", event => {
            event.preventDefault();

            const employee = parseInt(event.target.employee.value);

            gesso.postJSON("/api/bill/create", {
                appointment: parseInt(event.target.appointment.value),
                amount_due: parseInt(event.target["amount-due"].value),
            });

            this.router.navigate(new URL(`/employee?id=${employee}&tab=bills`, window.location));
        });
    }

    update() {
        const countryCode = localStorage.getItem("countryCode");
        gesso.fetchJSON("/api/data/proxy", data => {
            $("#bill-create-form").reset();

            const appointment = data.appointments[$p("appointment")];
            const appointmentRequest = data.appointment_requests[appointment.appointment_request_id];
            const customer = data.patients[appointmentRequest.patient_id];

            $("#appointment").setAttribute("value", appointment.id);
            $("#customer").setAttribute("value", customer.id);
            $("#employee").setAttribute("value", appointment.doctor_id);
            $("#customer-name").setAttribute("value", customer.name);
            $("#appointment-datetime").setAttribute("value", new Date(appointment.datetime).toLocaleString());
        }, null, {"Country-Code": countryCode});
    }
}

const payHtml = `
<body class="excursion">
  <section>
    <div>
      <h1>Pay a bill</h1>
      <form id="bill-pay-form">
        <input type="hidden" id="bill" name="bill"/>
        <input type="hidden" id="customer" name="customer"/>

        <div class="form-field">
          <div>Bank Employee</div>
          <div><input id="employee" name="employee" readonly="readonly"/></div>
          <div>Your Bank employee for this appointment</div>
        </div>

        <div class="form-field">
          <div>Appointment</div>
          <div><input id="appointment-datetime" name="appointment-datetime" readonly="readonly"/></div>
          <div>The date and time of your visit</div>
        </div>

        <div class="form-field">
          <div>Amount due</div>
          <div>
            <input id="amount-due" readonly="readonly" name="amount-due"/>
          </div>
          <div>The amount to pay</div>
        </div>

        <div class="form-field">
          <div>Credit card number</div>
          <div>
            <input name="credit-card-number" required="required" value="4005 5192 0000 0004"/>
          </div>
          <div>The credit card to pay with</div>
        </div>

        <div class="form-buttons">
          <button type="submit">Submit payment</button>
        </div>
      </form>
    </div>
  </section>
</body>
`;

export class PayPage extends gesso.Page {
    constructor(router) {
        super(router, "/bill/pay", payHtml);

        this.body.$("#bill-pay-form").addEventListener("submit", event => {
            event.preventDefault();

            const bill = parseInt(event.target.bill.value);
            const customer = parseInt(event.target.customer.value);


            main.router.navigate(new URL(`/customer?id=${customer}&tab=bills`, window.location));

            const countryCode = localStorage.getItem("countryCode");
            gesso.postJSON("/api/bill/pay", {bill: bill}, null, null, {"x-country-code": countryCode});

            main.router.navigate(new URL(`/customer?id=${customer}&tab=bills`, window.location));
        });
    }

    update() {
        const proxyHost = "/api/data/proxy";
        const countryCode = localStorage.getItem("countryCode");

        gesso.fetchJSON(proxyHost, data => {
            $("#bill-pay-form").reset();

            const bill = data.bills[parseInt($p("id"))];
            const appointment = data.appointments[bill.appointment_id];
            const appointmentRequest = data.appointment_requests[appointment.appointment_request_id];
            const employee = data.doctors[appointment.doctor_id];

            $("#bill").setAttribute("value", bill.id);
            $("#customer").setAttribute("value", appointmentRequest.patient_id);
            $("#appointment-datetime").setAttribute("value", new Date(appointment.datetime).toLocaleString());
            $("#employee").setAttribute("value", employee.name);
            $("#amount-due").setAttribute("value", bill.amount_due);
        }, null, {"Country-Code": countryCode});
    }
}
