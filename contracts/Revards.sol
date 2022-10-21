// // SPDX-License-Identifier: MIT

// pragma solidity ^0.8.0;

// import "./TinToken.sol";
// import {NFTinStorage} from "./NFTinStorage.sol";

// contract ActivityReward is NFTinStorage, TinToken {
//     uint activitiesPerDay;
//     uint tokensPerDay;
//     uint activityPerWeekOnNft = 1;
//     uint activities;
//     uint activitiesAtAll;
//     uint userK;
//     uint oneDayTokens;

//     mapping(address => uint) nftRate;
//     mapping(address => uint) userRate;
//     uint[] allNfts;

//     function registrationBonus(address _newUser) public {        
//         balances[_newUser] += 10 ether;
//         balances[thisOwner]-= 10 ether;
//     }

//     function getNftRate(address _nftAddr) public {
//         if(activitiesPerDay > 0) {
//             activities++;
//             activitiesPerDay--;
//         }
//         nftRate[_nftAddr] = activities;
//         allNfts.push(activities); // после каждого лайка добавляется новое число в массив?
//     }

//     function getUserRate(address _user) public {
//         userRate[_user] = activitiesAtAll;
//         for(uint i = 0; i < allNfts.length; i++) {
//             activitiesAtAll = allNfts[i]; // + ?????
//         }
//         userK = activitiesAtAll  / 10000;
//     }

//     function getReward(address _user) public {
//         // tokensPerDay = 100 - обновляем каждый день
//         oneDayTokens = 0.01 * activitiesAtAll;
//         if(tokensPerDay > 0) {
//             _user.balance += oneDayTokens;
//             tokensPerDay -= oneDayTokens;
//         }
//     }
// }


//     Пользователь:
//  r = A1 + A2 + … + An
//  где r - рейтинг NFT, А - активность (коммент, лайк)

//  UR = r1 + r2 + … + rn,
//  где UR - рейтинг пользователя, rn - рейтинг каждой NFT

//  К = 0.0001 * UR,
//  где K - коэффициент пользователя

// Ограничения:
//  В сутки:
//  - получить не более 100 токенов
//  - сделать не более 24 активностей
//  В неделю:
//  - не больше 1 активности к одной и той же NFT

// Стоимость:
//  цена размещения NFT = 1 токен * K
//  цена 1 актиности = (1 токен + r) / 100

// Награды:
//  забрать токены = 0.01 * r