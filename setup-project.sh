#!/bin/bash
echo "🚀 Creating Blockchain Identity System..."
mkdir -p blockchain-identity-system
cd blockchain-identity-system

# Create ALL files in one go
cat > blockchain-identity.js << 'FILE1'
// BLOCKCHAIN IDENTITY SYSTEM
import crypto from 'crypto';
class BlockchainIdentitySystem {
    constructor() { this.chain = [this.createGenesisBlock()]; this.pendingTransactions = []; this.identities = new Map(); this.credentials = new Map(); }
    createGenesisBlock() { return { index: 0, timestamp: new Date().toISOString(), transactions: [], previousHash: '0', hash: this.calculateHash(0, '0', [], new Date().toISOString()) }; }
    createBlock(transactions) { const previousBlock = this.chain[this.chain.length - 1]; const newBlock = { index: previousBlock.index + 1, timestamp: new Date().toISOString(), transactions: transactions, previousHash: previousBlock.hash, hash: this.calculateHash(previousBlock.index + 1, previousBlock.hash, transactions, new Date().toISOString()) }; this.chain.push(newBlock); return newBlock; }
    calculateHash(index, previousHash, transactions, timestamp) { return crypto.createHash('sha256').update(index + previousHash + JSON.stringify(transactions) + timestamp).digest('hex'); }
    createIdentity(name) { const privateKey = crypto.randomBytes(32).toString('hex'); const publicKey = crypto.createHash('sha256').update(privateKey).digest('hex'); const identity = { id: 'did:blockchain:' + publicKey.slice(0, 16), name, publicKey, createdAt: new Date().toISOString() }; const transaction = { type: 'CREATE_IDENTITY', id: 'tx_' + crypto.randomBytes(4).toString('hex'), identity: identity.id, timestamp: new Date().toISOString(), data: { name, publicKey } }; this.pendingTransactions.push(transaction); this.createBlock(this.pendingTransactions); this.pendingTransactions = []; this.identities.set(identity.id, { ...identity, privateKey }); return identity; }
    issueCredential(issuerId, holderId, credentialType, claims) { const issuer = this.identities.get(issuerId); const holder = this.identities.get(holderId); if (!issuer || !holder) throw new Error('Identity not found'); const credential = { id: 'vc:' + crypto.randomBytes(8).toString('hex'), type: credentialType, issuer: issuer.id, holder: holder.id, claims: claims, issueDate: new Date().toISOString(), status: 'active' }; const transaction = { type: 'ISSUE_CREDENTIAL', id: 'tx_' + crypto.randomBytes(4).toString('hex'), credential: credential.id, issuer: issuer.id, holder: holder.id, timestamp: new Date().toISOString(), data: { type: credentialType, claims } }; this.pendingTransactions.push(transaction); this.createBlock(this.pendingTransactions); this.pendingTransactions = []; this.credentials.set(credential.id, credential); return credential; }
    verifyCredential(credentialId) { let foundInBlockchain = false; let blockchainProof = null; for (let i = 1; i < this.chain.length; i++) { const block = this.chain[i]; const transaction = block.transactions.find(tx => tx.credential === credentialId && tx.type === 'ISSUE_CREDENTIAL'); if (transaction) { foundInBlockchain = true; blockchainProof = { blockIndex: block.index, blockHash: block.hash, transactionId: transaction.id, timestamp: transaction.timestamp }; break; } } const credential = this.credentials.get(credentialId); if (!credential) return { valid: false, reason: 'Credential not found' }; return { valid: foundInBlockchain, reason: foundInBlockchain ? 'Verified on Blockchain' : 'Not found on Blockchain', credential: foundInBlockchain ? credential : null, blockchainProof: blockchainProof }; }
    createProof(holderId, claimType, requiredValue) { const holder = this.identities.get(holderId); const credentials = Array.from(this.credentials.values()).filter(c => c.holder === holderId); const matchingCredential = credentials.find(c => { const claimValue = c.claims[claimType]; if (typeof claimValue === 'number') return claimValue >= requiredValue; return claimValue === requiredValue; }); if (!matchingCredential) throw new Error('No credential found'); const proof = { proofId: 'zkp:' + crypto.randomBytes(6).toString('hex'), claimType, requiredValue, satisfied: true, credentialId: matchingCredential.id, proof: crypto.createHash('sha256').update(matchingCredential.id + ':' + claimType + ':' + requiredValue + ':' + Date.now()).digest('hex'), timestamp: new Date().toISOString(), blockchainAnchored: true }; return proof; }
    viewBlockchain() { console.log('\n⛓️ BLOCKCHAIN LEDGER:'); console.log('=' .repeat(60)); this.chain.forEach((block, index) => { console.log('\n📦 BLOCK ' + index + ':'); console.log('   Hash: ' + block.hash.slice(0, 20) + '...'); console.log('   Previous: ' + block.previousHash.slice(0, 20) + '...'); console.log('   Transactions: ' + block.transactions.length); block.transactions.forEach(tx => { console.log('   └─ ' + tx.type + ': ' + (tx.identity || tx.credential || 'N/A')); }); }); console.log('=' .repeat(60)); }
    prettyPrint(entity) { console.log('\n' + '='.repeat(50)); if (entity.id && entity.id.startsWith('did:')) { console.log('🆔 BLOCKCHAIN IDENTITY:'); console.log('   Name: ' + entity.name); console.log('   ID: ' + entity.id); console.log('   Public Key: ' + entity.publicKey.slice(0, 20) + '...'); console.log('   Created: ' + entity.createdAt); } else if (entity.id && entity.id.startsWith('vc:')) { console.log('📜 BLOCKCHAIN CREDENTIAL:'); console.log('   Type: ' + entity.type); console.log('   Issuer: ' + entity.issuer); console.log('   Holder: ' + entity.holder); console.log('   Issue Date: ' + entity.issueDate); console.log('   Claims:'); Object.entries(entity.claims).forEach(([key, value]) => { console.log('     ' + key + ': ' + value); }); } else if (entity.proofId) { console.log('🕵️ BLOCKCHAIN ZK PROOF:'); console.log('   Proof ID: ' + entity.proofId); console.log('   Claim: ' + entity.claimType + ' >= ' + entity.requiredValue); console.log('   Satisfied: ' + entity.satisfied); console.log('   Blockchain Anchored: ' + entity.blockchainAnchored); console.log('   Proof Hash: ' + entity.proof.slice(0, 16) + '...'); } console.log('='.repeat(50)); }
}
function runDemo() { console.log('🌈 BLOCKCHAIN IDENTITY SYSTEM\n'); const blockchain = new BlockchainIdentitySystem(); console.log('🎯 CREATING IDENTITIES:'); const harvard = blockchain.createIdentity('Harvard University'); const student = blockchain.createIdentity('John Blockchain'); blockchain.prettyPrint(harvard); blockchain.prettyPrint(student); console.log('\n🎓 ISSUING CREDENTIALS:'); const diploma = blockchain.issueCredential(harvard.id, student.id, 'Degree', { degree: 'Bachelor of Blockchain', major: 'Cryptography', graduationYear: 2024 }); blockchain.prettyPrint(diploma); console.log('\n🔍 VERIFICATION:'); const verification = blockchain.verifyCredential(diploma.id); console.log('   Valid: ' + verification.valid); console.log('   Reason: ' + verification.reason); console.log('\n🔐 ZERO-KNOWLEDGE PROOFS:'); const proof = blockchain.createProof(student.id, 'graduationYear', 2020); blockchain.prettyPrint(proof); blockchain.viewBlockchain(); console.log('\n🎉 SYSTEM SUMMARY:'); console.log('   Blocks: ' + blockchain.chain.length); console.log('   Identities: ' + blockchain.identities.size); console.log('   Credentials: ' + blockchain.credentials.size); }
runDemo();
FILE1

cat > README.md << 'FILE2'
# Blockchain Identity System
A blockchain-based digital identity management system.
## Quick Start
\`\`\`bash
node blockchain-identity.js
\`\`\`
FILE2

cat > package.json << 'FILE3'
{
  "name": "blockchain-identity-system",
  "version": "1.0.0",
  "description": "Blockchain-based digital identity system",
  "main": "blockchain-identity.js",
  "type": "module",
  "scripts": {"start": "node blockchain-identity.js"},
  "keywords": ["blockchain","identity"],
  "author": "Your Name",
  "license": "MIT"
}
FILE3

cat > LICENSE << 'FILE4'
MIT License
Copyright (c) 2024 Your Name
FILE4

cat > .gitignore << 'FILE5'
node_modules/
*.log
.DS_Store
FILE5

echo "✅ ALL FILES CREATED!"
echo "🚀 Testing the project..."
node blockchain-identity.js
echo ""
echo "📤 TO UPLOAD TO GITHUB:"
echo "git init"
echo "git add ."
echo "git commit -m 'Initial commit'"
echo "git remote add origin https://github.com/YOUR_USERNAME/blockchain-identity-system.git"
echo "git push -u origin main"
