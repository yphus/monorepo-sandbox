#;**********************************************************************;
#
# Copyright (c) 2016, Intel Corporation
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without 
# modification, are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice, 
# this list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright notice, 
# this list of conditions and the following disclaimer in the documentation 
# and/or other materials provided with the distribution.
#
# 3. Neither the name of Intel Corporation nor the names of its contributors
# may be used to endorse or promote products derived from this software without
# specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF 
# THE POSSIBILITY OF SUCH DAMAGE.
#;**********************************************************************;
#!/bin/bash
alg_primary_obj=0x000B
alg_primary_key=0x0001
alg_create_obj=0x000B
alg_create_key=0x0008

file_primary_key_ctx=/root/context.p_"$alg_primary_obj"_"$alg_primary_key"
file_readpub_key_pub=/root/opu_"$alg_create_obj"_"$alg_create_key"
file_readpub_key_priv=/root/opr_"$alg_create_obj"_"$alg_create_key"
file_readpub_key_name=/root/name.load_"$alg_primary_obj"_"$alg_primary_key"-"$alg_create_obj"_"$alg_create_key"
file_readpub_key_ctx=/root/ctx_load_out_"$alg_primary_obj"_"$alg_primary_key"-"$alg_create_obj"_"$alg_create_key"
file_readpub_output=/root/readpub_ctx_load_out_"$alg_primary_obj"_"$alg_primary_key"-"$alg_create_obj"_"$alg_create_key"

Handle_readpub=0x81010014

fail()
{
	    echo "$1 test fail, please check the environment or parameters!"
        exit 1
}
Pass()
{
	    echo ""$1" pass" >>/root/test_getpubak_pass.log
}

rm $file_primary_key_ctx $file_readpub_key_pub $file_readpub_key_priv $file_readpub_key_name $file_readpub_key_ctx  $file_readpub_output  -rf

tpm2_takeownership -c

tpm2_createprimary -A e -g $alg_primary_obj -G $alg_primary_key -C $file_primary_key_ctx
if [ $? != 0 ];then
	 fail createprimary 
fi
tpm2_create -g $alg_create_obj -G $alg_create_key -o $file_readpub_key_pub -O $file_readpub_key_priv  -c $file_primary_key_ctx
if [ $? != 0 ];then
	fail create 
fi

tpm2_load -c $file_primary_key_ctx  -u $file_readpub_key_pub  -r $file_readpub_key_priv -n $file_readpub_key_name -C $file_readpub_key_ctx
if [ $? != 0 ];then
	fail load   
fi

tpm2_readpublic -c $file_readpub_key_ctx -o $file_readpub_output
if [ $? != 0 ];then
	fail decrypt 
fi

#####handle testing
tpm2_evictcontrol -A o -c $file_readpub_key_ctx  -S $Handle_readpub
if [ $? != 0 ];then
	fail evict 
fi
 
rm $file_readpub_output -rf
tpm2_readpublic -H $Handle_readpub -o $file_readpub_output
if [ $? != 0 ];then
	fail readpublic_handle 
fi

echo "readpublic test OK!"

