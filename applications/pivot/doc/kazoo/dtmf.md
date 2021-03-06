/*
Section: Pivot
Title: DTMF
Language: en-US
Version: 3.18
*/

# Overview

Sending DTMF to the caller is sometimes necessary (automating IVR navigation, perhaps). Use the `send_dtmf` callflow to do so.

## Example

    {"module":"send_dtmf"
     ,"data":{
         "digits":"123ABC#"
         ,"duration_ms":2000
     }
     ,"children":{}
    }

* `digits` is a string of DTMF to send.
* `duration_ms` is how long of a tone to send each DTMF (and optional)

The above example would send "1", "2", "3", "A", "B", "C", and finally "#", each as 2 second tones.
