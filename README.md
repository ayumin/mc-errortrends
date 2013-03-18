# Machine Cloud Error Trends

Watches for Salesforce Case creation, triggers a Chatter post if thre frequency goes over a threshold.

## ENV Vars

* `CASE_COUNT_THRESHOLD`
* `CASE_TIME_THRESHOLD`
* `CHATTER_GROUP_ID`
* `SALESFORCE_USERNAME`
* `SALESFORCE_PASSWORD`

If more than `CASE_COUNT_THRESHOLD` Cases of type `CASE_TYPE` are opened in `CASE_TIME_THRESHOLD` seconds,
a post will be created on the `CHATTER_GROUP_ID` Chatter Group.
