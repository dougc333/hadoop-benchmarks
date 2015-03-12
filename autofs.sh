#!/bin/bash -p

ssh root@r2371-d5-us01 "chkconfig autofs off; service autofs stop"
ssh root@r2371-d5-us02 "chkconfig autofs off; service autofs stop"
ssh root@r2371-d5-us03 "chkconfig autofs off; service autofs stop"
ssh root@r2371-d5-us04 "chkconfig autofs off; service autofs stop"
ssh root@r2371-d5-us05 "chkconfig autofs off; service autofs stop"
ssh root@r2371-d5-us06 "chkconfig autofs off; service autofs stop"
ssh root@r2371-d5-us07 "chkconfig autofs off; service autofs stop"
ssh root@r2371-d5-us08 "chkconfig autofs off; service autofs stop"
ssh root@r2371-d5-us09 "chkconfig autofs off; service autofs stop"
ssh root@r2371-d5-us10 "chkconfig autofs off; service autofs stop"

