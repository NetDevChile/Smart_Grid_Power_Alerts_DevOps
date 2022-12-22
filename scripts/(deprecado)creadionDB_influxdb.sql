  auth
  admin
  strong_password
CREATE DATABASE "telegraf" WITH DURATION 53w1d REPLICATION 1 NAME "one_year"
  show databases
  use telegraf

  SHOW RETENTION POLICIES

  create user "telegraf_r" with password 'strong_password';
  create user "telegraf_w" with password 'strong_password';

  grant read on "telegraf" to "telegraf_r";
  grant write on "telegraf" to "telegraf_w";