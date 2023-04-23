# Final Project: Upgrade UniswapV2

UniswapV2 was written three years ago and uses outdated versions of Solidity tools

### Project goals:
* Achieve deep knowledge of the UniswapV2 implementation
* Learn Foundry, the next generation ethereum development environment
* You may use any online resources for the project.
* Read through the UniswapV2 code:
  ** https://github.com/Uniswap/v2-core
  ** https://github.com/Uniswap/v2-periphery
  ** Class Notes (written by Jichu Wang, a former student at NEU).
  
* Copy the UniswapV2 code into a new Foundry project
* The original code had the core and periphery contracts in different repos. We recommend combining them into a single repo to simplify development, and copying libraries rather than using package management.
* UniswapV2Router01 should not be included.
* Upgrade the UniswapV2 code to the latest Solidity version that Foundry supports.
* Write Solidity tests that achieve >95% line coverage for each of the following contracts:
 ** UniswapV2Router02
 ** UniswapV2Pair
 ** UniswapV2Factory
* Generate and commit a line coverage report to assess the quality of your tests
![alt text](https://github.com/ymayank97/Uniswapv2_upgrade/blob/master/coverage.png?raw=true)
