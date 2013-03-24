# Machine Cloud Error Trends

This app implements a simple workflow for automatically creating service requests in Service Cloud and escalating issues to Salesforce Chatter. Specifically the following behavior is implemented:

Watches the logplex event stream for device failures of the specified `CASE_TYPE` and creates case using the Force.com REST API. 
Watches Service Cloud for `CASE_COUNT_THRESHOLD` occurrences of `CASE_TYPE` within `CASE_TIME_THRESHOLD` and posts to `CHATTER_GROUP_ID` via the Force.com REST API

## ENV Vars

* `CASE_COUNT_THRESHOLD`
* `CASE_TIME_THRESHOLD`
* `CHATTER_GROUP_ID`
* `SALESFORCE_USERNAME`
* `SALESFORCE_PASSWORD`

If more than `CASE_COUNT_THRESHOLD` Cases of type `CASE_TYPE` are opened in `CASE_TIME_THRESHOLD` seconds,
a post will be created on the `CHATTER_GROUP_ID` Chatter Group.
