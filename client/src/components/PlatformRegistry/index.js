import React, { Component } from "react";
import getWeb3, { getGanacheWeb3, Web3 } from "../../utils/getWeb3";

import App from "../../App.js";

import { Typography, Grid, TextField } from '@material-ui/core';
import { ThemeProvider } from '@material-ui/styles';
import { theme } from '../../utils/theme';
import { Loader, Button, Card, Input, Heading, Table, Form, Flex, Box, Image, EthAddress } from 'rimble-ui';
import { zeppelinSolidityHotLoaderOptions } from '../../../config/webpack';

import styles from '../../App.module.scss';
//import './App.css';


export default class PlatformRegistry extends Component {
  constructor(props) {    
    super(props);

    this.state = {
      /////// Default state
      storageValue: 0,
      web3: null,
      accounts: null,
      route: window.location.pathname.replace("/", "")
    };

    this.getTestData = this.getTestData.bind(this);
  }

 
  _createSreamingMoney = async () => {
    const { accounts, platform_registry, web3 } = this.state;

    // const recipient = "0xad6d458402f60fd3bd25163575031acdce07538d";
    // const deposit = "299999999999999894400";             // almost 3,000, but not quite
    // const tokenAddress = "0xad6d458402f60fd3bd25163575031acdce07538d";  // DAI on ropsten
    // const now = Math.round(new Date().getTime() / 1000);  // get seconds since unix epoch
    // const startTime = now + 3600;                         // 1 hour from now
    // const stopTime = now + 2592000 + 3600;                // 30 days and 1 hour from now

    let stream = await platform_registry.methods.createSreamingMoney().send({ from: accounts[0] })
    // let stream = await platform_registry.methods.createSreamingMoney(recipient, 
    //                                                                  deposit, 
    //                                                                  tokenAddress, 
    //                                                                  startTime, 
    //                                                                  stopTime).send({ from: accounts[0] })
    console.log('=== response of createSreamingMoney() function ===', stream);        
  }


  getTestData = async () => {  // This codes of async is referenced from OceanProtocol / My Little Ocean
    const { accounts, platform_registry, web3 } = this.state;

    const response_1 = await platform_registry.methods.testFunc().send({ from: accounts[0] })
    console.log('=== response of testFunc() function ===', response_1);
  }





  //////////////////////////////////// 
  ///// Refresh Values
  ////////////////////////////////////
  refreshValues = (instancePlatformRegistry) => {
    if (instancePlatformRegistry) {
      console.log('refreshValues of instancePlatformRegistry');
    }
  }


  //////////////////////////////////// 
  ///// Ganache
  ////////////////////////////////////
  getGanacheAddresses = async () => {
    if (!this.ganacheProvider) {
      this.ganacheProvider = getGanacheWeb3();
    }
    if (this.ganacheProvider) {
      return await this.ganacheProvider.eth.getAccounts();
    }
    return [];
  }

  componentDidMount = async () => {
    const hotLoaderDisabled = zeppelinSolidityHotLoaderOptions.disabled;
 
    let PlatformRegistry = {};
    try {
      PlatformRegistry = require("../../../../build/contracts/PlatformRegistry.json"); // Load ABI of contract of PlatformRegistry
    } catch (e) {
      console.log(e);
    }

    try {
      const isProd = process.env.NODE_ENV === 'production';
      if (!isProd) {
        // Get network provider and web3 instance.
        const web3 = await getWeb3();
        let ganacheAccounts = [];

        try {
          ganacheAccounts = await this.getGanacheAddresses();
        } catch (e) {
          console.log('Ganache is not running');
        }

        // Use web3 to get the user's accounts.
        const accounts = await web3.eth.getAccounts();
        // Get the contract instance.
        const networkId = await web3.eth.net.getId();
        const networkType = await web3.eth.net.getNetworkType();
        const isMetaMask = web3.currentProvider.isMetaMask;
        let balance = accounts.length > 0 ? await web3.eth.getBalance(accounts[0]): web3.utils.toWei('0');
        balance = web3.utils.fromWei(balance, 'ether');

        let instancePlatformRegistry = null;
        let deployedNetwork = null;

        // Create instance of contracts
        if (PlatformRegistry.networks) {
          deployedNetwork = PlatformRegistry.networks[networkId.toString()];
          if (deployedNetwork) {
            instancePlatformRegistry = new web3.eth.Contract(
              PlatformRegistry.abi,
              deployedNetwork && deployedNetwork.address,
            );
            console.log('=== instancePlatformRegistry ===', instancePlatformRegistry);
          }
        }

        if (PlatformRegistry) {
          // Set web3, accounts, and contract to the state, and then proceed with an
          // example of interacting with the contract's methods.
          this.setState({ 
            web3, 
            ganacheAccounts, 
            accounts, 
            balance, 
            networkId, 
            networkType, 
            hotLoaderDisabled,
            isMetaMask, 
            platform_registry: instancePlatformRegistry
          }, () => {
            this.refreshValues(
              instancePlatformRegistry
            );
            setInterval(() => {
              this.refreshValues(instancePlatformRegistry);
            }, 5000);
          });
        }
        else {
          this.setState({ web3, ganacheAccounts, accounts, balance, networkId, networkType, hotLoaderDisabled, isMetaMask });
        }
      }
    } catch (error) {
      // Catch any errors for any of the above operations.
      alert(
        `Failed to load web3, accounts, or contract. Check console for details.`,
      );
      console.error(error);
    }
  }



  render() {
    return (

      <div className={styles.widgets}>
        <Grid container style={{ marginTop: 32 }}>

          <Grid item xs={4}>

            <Card width={"auto"} 
                  maxWidth={"420px"} 
                  mx={"auto"} 
                  my={5} 
                  p={20} 
                  borderColor={"#E8E8E8"}
            >
              <h4>Platform Registry</h4>

              <Image
                alt="random unsplash image"
                borderRadius={8}
                height="100%"
                maxWidth='100%'
                src="https://source.unsplash.com/random/1280x720"
              />

              <Button size={'small'} mt={3} mb={2} onClick={this.getTestData}> Get TestData </Button> <br />
            </Card>
          </Grid>

          <Grid item xs={4}>
          </Grid>

          <Grid item xs={4}>
          </Grid>
        </Grid>
      </div>
    );
  }

}
