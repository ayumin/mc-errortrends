# Machine Cloud Error Trends

This app implements a simple workflow for monitoring Service Cloud for `CASE_COUNT_THRESHOLD` occurrences of `CASE_TYPE` within `CASE_TIME_THRESHOLD` and posts to `CHATTER_GROUP_ID` via the Force.com REST API when conditions are met.

* Watches 

## ENV Vars

* `CASE_COUNT_THRESHOLD`
* `CASE_TIME_THRESHOLD`
* `CHATTER_GROUP_ID`
* `SALESFORCE_USERNAME`
* `SALESFORCE_PASSWORD`

If more than `CASE_COUNT_THRESHOLD` Cases of type `CASE_TYPE` are opened in `CASE_TIME_THRESHOLD` seconds,
a post will be created on the `CHATTER_GROUP_ID` Chatter Group.
