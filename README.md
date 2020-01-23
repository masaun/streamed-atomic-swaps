# Streamed Atomic Swaps

***
## 【Introduction of Streamed Atomic Swaps】
- This is the "Streamed Atomic Swaps".
- This is dApp for "Streamed Atomic Swaps" by using sablier protocol.
- I implement "Streamed Atomic Swaps" in `./contracts/StreamedSwap.sol` especially.
  - Currently, I implement swap between DAI and BAT on ropsten.  (Both of value are static. So, I will replace value from static to dynamic in the future)

&nbsp;


***

## 【Setup】
### Setup wallet by using Metamask
1. Add MetaMask to browser (Chrome or FireFox or Opera or Brave)    
https://metamask.io/  


2. Adjust appropriate newwork below 
```
Ropsten Test Network
```

&nbsp;


### Setup backend
1. Deploy contracts to Kovan Test Network
```
(root directory)

$ npm run migrate:ropsten
```

&nbsp;


### Setup frontend
1. Execute command below in root directory.
```

$ npm run client
```

2. Access to browser by using link 
```
http://127.0.0.1:3000
```

&nbsp;

***


## 【Work flow】

&nbsp;

***

## 【References】  
- Gitcoin / Take Back the Web  
  https://gitcoin.co/issue/sablierhq/sablier/29/3870  

- Document of sablier protocol    
  - https://docs.sablier.finance/streams    
  - https://faq.sablier.finance/    

- Github of sablier protocol  
  - https://github.com/sablierhq/sablier  
 
- Discord of sablier protocol  
  https://discordapp.com/channels/659709894315868191/659713154288451623
