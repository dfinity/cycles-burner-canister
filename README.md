# cycles-burner-canister

<div>
  <p>
    <a href="https://github.com/dfinity/cycles-burner-canister/blob/master/LICENSE"><img alt="Apache-2.0" src="https://img.shields.io/github/license/dfinity/bitcoin-canister"/></a>
    <a href="https://internetcomputer.org/docs/current/references/ic-interface-spec#ic-bitcoin-api"><img alt="API Specification" src="https://img.shields.io/badge/spec-interface%20specification-blue"/></a>
    <a href="https://forum.dfinity.org/"><img alt="Chat on the Forum" src="https://img.shields.io/badge/help-post%20on%20forum.dfinity.org-yellow"></a>
  </p>
</div>

## Overview

Cycles burner canister burns cycles periodically to represent the usage of the subnet. 

Expected usage: 
<ul>
  <li>Cycles will be deposited to the cycles burner canister so the other canisters running on subnet would not be charged cycles for regular operations.</li>
  <li>Cycles burner canister will burn X amount of cycles on every interval of T seconds.</li>
</ul>
