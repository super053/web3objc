# web3objc
web3js objective c version(for ios)  



	struct	
			
		          
	web3	- sharedInstance()		
		- setEndPoint(endpoint,chainid)
		
		- *eth		- getGasPrice()	
				- getBlockNumber()	
				- getBalance(address)	
				- getTranactionCount(address)	
				- sendSignedTransaction(signedTx)	
				- signedTransaction(tx,privateKey)	
				- call(tx)	
				- estimateGas(tx)	
				- getChainId()
				
				- *contract	- initWithAddress(contract address)
			                    	- call(function str, argument...)
			                    	- encodeABI(function str, argument...)
			
		          	- *accounts	- create()
			                    	- privateKeyToAccount(privateKey)
			                    	- signTransaction(tx,privateKey)
			                    	- recoverTransaction(rawTx)
			                    	- hashMessage(string)
			                    	- sign(message, privateKey)
			                    	- recover(message, signature)
			                    	- encrypt(privateKey, password)
			                    	- decrypt(jsonDic, password) 
			
			
	    	- *utils	- randomHex(size)	
		           	- sha3(string)	
		           	- keccak256(string)	
		           	- toChecksumAddress(address)	
		           	- checkAddressChecksum(address)	
		           	- numberToHex(numberString)	
		           	- hexToNumber(hex)	
		           	- utf8ToHex(String)	
		           	- hexToUtf8(hex)	
		           	- toWei(number, unit)	
		           	- fromWei(number, unit)	
    
Pods/TrezorCrypto/aes.h 41: uncomment

coinvest ios & blockchain developer P.K. (Park Sung Sik)  
super053@gmail.com  
coinios1@coinvest.kr  



donation(ethereum) : 0xbef705eE6a72Cd35C2ED6b657dD4aC2c0AAB82b6

[![HitCount](http://hits.dwyl.com/super053/web3objc.svg)](http://hits.dwyl.com/super053/web3objc)
