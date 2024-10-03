import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const bankAccountModule = buildModule("bankAccountModule", (m) => {

    const bank = m.contract("bankAccount");

    return { bank };
});

export default bankAccountModule;
