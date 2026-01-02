require ["vnd.dovecot.pipe", "vnd.dovecot.execute", "variables", "envelope"];

# Is this for the WKS service?
if envelope :all :matches "to" "wkd-submission@*" {
  set :lower "domain" "${1}";
  if envelope :all :matches "from" "*@*" {
    set :lower "from" "${0}";
    # We know this is for the WKS service. But do the from & to domains match?
    if envelope :domain :is "from" "${domain}" {
      if not execute :pipe "process-wks-request.script" ["${domain}", "${from}"] {
        discard;
        stop;
      }
      discard;
      stop;
    }
    # If not, we don't want to process it nor do we want to deliver it.
    else {
      discard;
      stop;
    }
  }
}
