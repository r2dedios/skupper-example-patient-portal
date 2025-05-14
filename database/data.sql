drop table if exists bills;
drop table if exists appointments;
drop table if exists appointment_requests;
drop table if exists patients;
drop table if exists doctors;

create table patients (
    id                      serial primary key,
    name                    varchar not null,
    zip                     varchar not null,
    phone                   varchar not null,
    email                   varchar not null,
    country                 varchar not null
);

create table doctors (
    id                      serial primary key,
    name                    varchar not null,
    phone                   varchar,
    email                   varchar,
    country                 varchar not null
);

create table appointment_requests (
    id                      serial primary key,
    patient_id              integer not null references patients,
    datetime                timestamp not null,
    description             varchar not null
);

create table appointments (
    id                      serial primary key,
    appointment_request_id  integer not null references appointment_requests,
    doctor_id               integer not null references doctors,
    datetime                timestamp not null
);

create table bills (
    id                      serial primary key,
    appointment_id          integer not null references appointments,
    amount_due              integer not null,
    payment_datetime        timestamp
);

create or replace function notify_changes() returns trigger as $$
declare
begin
    raise warning 'Changes!';
    notify changes;
    return new;
end;
$$ language plpgsql;

create trigger patients_changes
after insert or update or delete or truncate on patients
execute procedure notify_changes();

create trigger doctors_changes
after insert or update or delete or truncate on doctors
execute procedure notify_changes();

create trigger appointments_changes
after insert or update or delete or truncate on appointments
execute procedure notify_changes();

create trigger appointment_requests_changes
after insert or update or delete or truncate on appointment_requests
execute procedure notify_changes();

create trigger bills_changes
after insert or update or delete or truncate on bills
execute procedure notify_changes();

insert into patients
  (name, zip, phone, email, country)
values
  ('B-LV-A.MAzizQMiRNmjYrDqfiRguHZ5V6emkzXaYgVN2+c(','01821','B-LX-A.8M1c3pWn+jrlJLtsxIDpGSmsRle8uc9zVdHbsA)','B-LW-A.:8beSGOJKiPLP8FZDtF:hP5mVG+rd2ajSccv3HiyOwbeRg)','GB'),
  ('B-LY-A.1aMj2o:YRVCl5ok4aMrX::N5yGmUPjXw448peq6T','02143','B-La-A.H5NLuf2JSFjdrsm9OgYKKdq63AjM7OIBau90fg)','B-LZ-A.bkYpd8+MMVYRO8Xg4EXFjCoMEUMKJAjOodXN2hpUwOHgDjclcg)','CH'),
  ('B-LV-A.NgPnzU8PAeOrY9sPvXaIyr0881Ra:xteQHM(','12345','B-LX-A.98hf3pCi:DrmJrBhLJthiPFoY8UKBbjTcZrSkQ)','B-LW-A.4cLVT2OEBSjeP8JpB8wwh+t+Zw8CPUAEXwQ7:R29L784Ni9eOoFd','GB'),
  ('B-LY-A.270nna:NCXOj:I8sHH4jOLgn1pS6U34ogxqK','98823','B-La-A.HJdJuf6KTljbqMay1WYC0MishRXAbIITfq5Kyw)','B-LZ-A.fkotetmOP2YHA8H18UTQziFHC8JqcEOVTZ0fu26j71GrGvU(','CH'),
  ('B-LV-A.OgfpxBZjL:Wyf6vxvsSU7yYtJzOqM3WyuiyU6w)','12345','B-LX-A.98hf3paq:jrkIbtqkVW2ggwMP3i4OT0lcj8RIw)','B-LW-A.8NzDSmiVGTXRHslRA9khhv48bEQY0lCUwIN61Sx8R982+3gDKw)','GB'),
  ('B-Lb-A.mnJ9zO1t9Okb1MoFT8Yjf0Lt6xlEQ+Ok:HSEeA)','12345','B-Lc-A.mhepbfrkiaYw55l8vG7FYJABTzYj6oRMZnYe9g)','B-Lc-A.zE3zK6Kz1+Rtp9ksTLlj2O3K9Vp:UT:HvZA:WirUyV24IBK3LVA68h0(','US'),
  ('B-LV-A.PAvmwA4mCLSRc6v3ZAvejHjaI9PKayl8NOA4t7w(','12345','B-LX-A.98hf3piq+DrgJb1sp9nqTulPr37O7OWdrGRZtw)','B-LW-A.4crRUWiwDz7SM9xFB5o:j+:ZgC+TuSDnhMnnBUzbJZEq','GB'),
  ('B-LY-A.3qcp3JWMKGK0+pIjedWbZ2mcDK3nXFwdh7pR4zS:','12345','B-La-A.H5NLufmMT1jbq8S:CxKVBktRgn7BmeILlScBHA)','B-LZ-A.fUA+e82MMl8iHtj57FjZhWFMGlITvfA3rd6k4AJHCf7zpQXd','CH'),
  ('B-Lb-A.gXZmhcEo3Psbws3fyuXM9oWIhBU9ueKaMds(','02474','B-Lc-A.mhKlbfnniaY67Z14vM9UWh51vWsPSLf2OKkS9Q)','B-Lc-A.30PxMKq7+u57tcA5UpwozunTZFjAQhAMQ7DVg2Xwxj0AkA)','US'),
  ('B-Lb-A.g25qy6MF1v8WycCALNQUmb1E6K8RFvPmBBrD','88642','B-Lc-A.nRWobfzjjqYx45RxOMzIk6U:y8pjh4KZRa0X3Q)','B-Lc-A.20fxMIuzwupupMEsEJdj1Gcai9xJ2mJa1R8:b7DUUko(','US'),
  ('B-LY-A.xbsoxMfqCWao6p4:b8DLTEFA08bSNYAc:rNwVtzzRA)','99891','B-La-A.H5NLuf6OQljepsa6cu22Idus69k6PYJKF0CGMQ)','B-LZ-A.aEsvecOSLVIiHtj57FjZhWFMGlLdbTpPi3XFra2Dye+FrggU','CH');

insert into doctors
  (name, phone, email, country)
values
  ('B-Lb-A.k3Jlz+Ig0OZX680F0kfe+7GMSAYhvdJhEkf8FK2Vxw)','B-Ld-A.fW3A85KphdoSdQ0uwE5y87fXDwYmpLAApHLhyQ)','B-Lc-A.x0PrK66v38tmrMwkTpVjjuLC8Ryqt1Wve8ExIAngQwSXzMU(','US'),
  ('B-LV-A.MwfzzR0vHbSBYrHweNdaF793TnOvzmVrN9N+9nUdGA)','B-LX-A.98hf3pSn+jrjJrlr1F9MiRxBT9tVT0:CuLmxuQ)','B-LW-A.9cjERnWwDz7SM9xFB5o:j+84eUS0b2LkruFiYxbNsBUS','GB'),
  ('B-LY-A.1bE42IyMNmuj:pMobssaMdOJdDLNqysaaC30xTb1','B-La-A.H5NLufmMT1jfrsC62pG3VCylJBSrpsknudIp3Q)','B-LZ-A.cUAufMmBM18iHtj57FjZhWFMGlLfYPPIeFG2b7KixRcbmodH','CH'),
  ('B-Lb-A.lXhkwuoomcAYzNcF0hoKFh1BY9JXtVr+gjyZx1Y(','B-Ld-A.fW3A85KphdoSdQ0s2Q5a5E2IfkxGsNGI:UnGfg)','B-Lc-A.wUf1LIuzwupupMEsEJdj1DyAKOUn0f6R8K29bbcfuaE(','US'),
  ('B-LV-A.NhDgzwAxHbSKf7Hwdf:3NztQ3GOgiUuhRJwPpmQ(','B-LX-A.98hf3pSn+jrjJrholPeQa02fRW9VfsOa7b:Lkw)','B-LW-A.+tzXS0aVEifeLsBMTNo0nkbXs9k8rhJBaiOR3OTubqQ(','GB'),
  ('B-LV-A.Oyal7AAxDfWsHAKV1X86GHAoVh0wKCbS8g)','B-LX-A.98hf3pSn+jrjJrhrkvZrA9LM08tlLmDrls1Wug)','B-LW-A.8MjdQW+wDz7SM9xFB5o:j+8WQak1b9I:G4wm0TaTE:KT','GB'),
  ('B-LY-A.3bEl04beASOL7bgiZaaz0b:GrKZ4a+3Rcqf51lQ(','B-La-A.H5NLufmMT1jfrsG+n3sC36vmElAGowX+K6Kf0Q)','B-LZ-A.fkwka9+gO14DFtD05AbbhTtmcvV+3bV5j:OaU318rc9q','CH'),
  ('B-LY-A.3LE42IPFEWvmyYkoZf1AzBJxloKBkYYjI8q5n3o(','B-La-A.H5NLufmMT1jfrsC5SZOAVrp3q3P7ExAWFdSiKA)','B-LZ-A.bEY4fcOOHkMaGs3o7U2bjipW5HiFrslxyNTFEDnCNXa+Qg)','CH'),
  ('B-LV-A.PAvmwA4mCPXiQbHqftxTsLdP9qouys7AvaV3QCqF','B-LX-A.98hf3pSn+jrjJrls2lwTf6go7w8l3mgPZ3L:DA)','B-LW-A.9tvdSm2VKiPLP8FZDtF:hP5m7BZWF4BaSlDq+bcYyAnUMg)','GB'),
  ('B-Lb-A.nH55xO0p2Kg12s0MxV0QzNFg0lbhnV+MMOVMJEPA','B-Ld-A.fW3A85KphdoSdQ0pBi4ewEQZJH22kiJcY6Iayw)','B-Lc-A.zEr1Ja2W3:Niud0lW9doxfh86llNURtTGJM6bdsG54VR','US');

insert into appointment_requests (patient_id, datetime, description)
values (1, current_timestamp, 'Knee surgery');

insert into appointment_requests (patient_id, datetime, description)
values (1, current_timestamp, 'Routine checkup');

insert into appointments(appointment_request_id, doctor_id, datetime)
values (1, 1, current_timestamp);

insert into bills(appointment_id, amount_due)
values (1, 400);

insert into appointment_requests (patient_id, datetime, description)
values (2, current_timestamp, 'Concussion');

insert into appointments(appointment_request_id, doctor_id, datetime)
values (3, 2, current_timestamp);

insert into bills(appointment_id, amount_due)
values (2, 350);
