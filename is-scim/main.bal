import ballerina/http;
import ballerina/mime;

string SCIM_ME_ENDPOINT = "https://4328ed1d-5fa7-492d-aea9-8f07d12f8546-dev.e1-us-east-azure.choreoapis.dev/plto/default/v1.0/scim2/Me";

type User readonly & record {|
    string username;
    string password;
|};

service /user on new http:Listener(9090) {
    resource function get greeting() returns string {
        return "Hello, World!";
    }

    resource function get greeting/[string name]() returns string {
        return "Hello " + name;
    }

    resource function post validateUser(User user) returns string|error|json {
        string username = user.username;
        string password = user.password;
        string credentials = username + ":" + password;
        var encodedVar = mime:base64Encode(credentials);
        string base64Credentials = "Basic ";
        if (encodedVar is string) {
            base64Credentials = base64Credentials + encodedVar;
        }

        http:Client isClient = check new(SCIM_ME_ENDPOINT);

        http:Response response = check isClient->/({
            Authorization: base64Credentials
        });
        
        if (response.statusCode == http:STATUS_OK) {
            return {"statusCode": 200, "status": "Valid user credentials"};
        } else {
            return {"statusCode": 400, "status": "Invalid user credentials"};
        }
    }
}