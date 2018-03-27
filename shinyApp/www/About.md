
### **klondik.io - A Bitcoin Compliance Toolbox**

This website aims at helping compliance departments in their tasks of onboarding bitcoin clients. This will help you:
* retrieving bitcoin transactions in an analysis-friendly way,
* confronting the client's trade (hi)story,
* identifying all addresses owned by the client,
* identify fraudulent transactions (mixers) through graphs,
* checking whether the address(es) has been reported by other bitcoin users as scam.

**Warning** Being based on the blockchain.info API, massive transactions queries might take a while. we are currently working on a dedicated database with improved capabilities.
<br>
<br>

For any by bug report, improvements or enquiries, please contact us at <bitcompliance@klondik.io>.
<br>
<br>

#### **New Search**
* Initiate transactions search.
* The list of addresses must be a .csv file. The file should not contain any column names or any other data than the addresses of interest.
* If both a .csv list and an address have been entered, priority is given to the single address. To search for the list instead, erase the address in the field.
* If a list of addresses has been uploaded and searched, a New Search on a single address resets the results and discards the list.
* Conversely, a New Search on list of addresses after a single address search resets the single address results.
<br>
<br>

#### **Add Search**
* Enter a BTC address in the text input, and click Add Search.
* Appending a list of addresses is not supported.
* The results will be appended to the existing transactions results.
<br>
<br>

#### **Cluster**
* Finding addresses that belong to the same owner based on the transactions inputs.
* Only transactions with number of inputs <10 are considered to avoid clustering mixing transactions, etc.
* Addresses identified are automatically added to the "All Addresses" tab.
<br>
<br>

#### **Get New Transactions button**
* In the Cluster tab, launches a transactions search on all identified addresses from the clustering.
* Flushes the Cluster tab to allow for clustering from the new transactions.
* Addresses identified through clustering are automatically saved in the "All Addresses" tab.
<br>
<br>

#### **Scam Report**
* Scam report relies on a third-party API with limited connection bandwidth. Requests on large sets can take a while.
* Reports are queried on the searched addresses (=/= All Addresses, see "Cluster").
* Reports are not queried for clustered addresses that have not been searched through "Get cluster".
* The third-party API relies itself on BTC users reports. Scam description is unstandardized and reports value is hence left to the appreciation of the site's user.
<br>
<br>

#### **All Addresses tab**
* Lists all the addresses that have been searched by the user plus all addresses identified through clustering.
* The list does include addresses that have not yet been searched through the "Get new Transactions" button.
<br>
<br>

#### **Graph**
* Plots an interactive force network of the transactions.
* All addresses from the All Addresses Tab are given a specific dot color for identification.
* **Warning** plotting results with >10 000 transactions lines can severely slow your browser or crash it.
* The Graph button will graph the plot again should the transactions results have changed.
<br>
<br>

#### **Download Graph**
* Downloads the last graph drawn in html format.
* The file is named after the first address searched (New Search) or the first address in the list of addresses, in the form "firstAddress.html".
<br>
<br>

#### **Download Transactions**
* Download a .csv file of the current transactions results.
* The file is named after the first address searched (New Search) or the first address in the list of addresses, in the form "firstAddress.csv".
<br>
<br>
<br>
<br>
