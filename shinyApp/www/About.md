
### **Bitcompliance - a Bitcoin Compliance Toolbox**

This website aims at helping compliance departments in their tasks of onboarding bitcoin clients.

This will help you:

* **retrieving bitcoin transactions in an analysis-friendly way,**
* **confronting the client's trade (hi)story,**
* **identifying all addresses owned by the client,**
* **identify fraudulent transactions (mixers) through graphs,**
* **checking whether the address(es) has been reported by other bitcoin users as scam.**

**Warning** Being based on the blockchain.info API, massive transactions queries might take a while. We are currently working on a dedicated database with improved capabilities.
<br>
<br>

For any by bug report, improvements or enquiries, please contact us at <bitcompliance@klondik.io>.
<br>
<br>

**Quick Guide to the App**

* [New Search](#New Search)
* [Add Search - Add a new search to the Results](#Add Search)
* [Transactions Summary - A summary of the Transactions Results](#Summary)
* [Cluster - Identify parent addresses](#Cluster)
* [Get Cluster Info - Get transactions from parent addresses](#Get New Transactions)
* [Scam Report - Were the addresses reported for Scam?](#Scam)
* [All Addresses Tab - List of all identified Addresses](#AllAddresses)
* [Graph - Graph the Transactions results](#Graph)
* [Download Transactions - Download the Transactions Results](#DLTransacs)
<br>
<br>

--------
<br>

#### **New Search** <a name="New Search"></a>
* Initiate transactions search.
* The list of addresses must be a .csv file. The file should not contain any column names or any other data than the addresses of interest.
* If both a .csv list and an address have been entered, priority is given to the single address. To search for the list instead, erase the address in the field.
* If a list of addresses has been uploaded and searched, a New Search on a single address resets the results and discards the list.
* Conversely, a New Search on list of addresses after a single address search resets the single address results.
<br>
<br>

#### **Add Search** <a name="Add Search"></a>
* Enter a BTC address in the text input, and click Add Search.
* Appending a list of addresses is not supported.
* The results will be appended to the existing transactions results.
<br>
<br>

#### **Summary** <a name="Summary"></a>
* Returns a summary of the transactions results.
* Results are given on the Searched addresses obtained through "New Search", "Add Search", or "Get Cluster" - set of addresses may not be equal to the "All Addresses" list. [See "All Addresses"](#AllAddresses).
<br>
<br>

#### **Cluster** <a name="Cluster"></a>
* Finding addresses that belong to the same owner based on the transactions inputs.
* Addresses identified are automatically added to the "All Addresses" tab.
<br>
<br>

#### **Get New Transactions button** <a name="Get New Transactions"></a>
* In the Cluster tab, launches a transactions search on all identified addresses from the clustering.
* Flushes the Cluster tab to allow for clustering from the new transactions.
* Addresses identified through clustering are automatically saved in the "All Addresses" tab.
<br>
<br>

#### **Scam Report** <a name="Scam"></a>
* Scam report relies on a third-party API with limited connection bandwidth. Requests on large sets can take a while.
* Reports are queried on the searched addresses (different from the "All Addresses" list, [see "Cluster"](#Cluster) and ["All Addresses"](#AllAddresses).
* Reports are not queried for clustered addresses that have not been searched through "Get cluster".
* The third-party API relies itself on BTC users reports. Scam description is unstandardized and reports value is hence left to the appreciation of the site's user.
<br>
<br>

#### **All Addresses tab** <a name="AllAddresses"></a>
* Lists all the addresses that have been searched by the user plus all addresses identified through clustering.
* The list does include addresses that have not yet been searched through the "Get new Transactions" button.
<br>
<br>

#### **Graph** <a name="Graph"></a>
* Plots an interactive force network of the transactions.
* All addresses from the All Addresses Tab are given a specific dot color for identification.
* **Warning** plotting results with >10 000 transactions lines can severely slow your browser or crash it.
* The Graph button will graph the plot again should the transactions results have changed.

**Download Graph** :
* Downloads the last graph drawn in html format.
* The file is named after the first address searched (New Search) or the first address in the provided list of addresses, in the form "firstAddress.html".
<br>
<br>

#### **Download Transactions** <a name="DLTransacs"></a>
* Download a .csv file of the current transactions results.
* The file is named after the first address searched (New Search) or the first address in the provided list of addresses, in the form "firstAddress.csv".
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
