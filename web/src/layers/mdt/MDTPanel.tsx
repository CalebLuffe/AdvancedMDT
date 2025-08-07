import React, { useState } from "react";
import { useMDTData, Evidence, Witness, Scenario, Case } from "./useMDTData";
import _ from "lodash";

export function MDTPanel({ userRole }) {
    const { cases, evidence, witnesses, scenarios, loading, error } = useMDTData();
    const [selectedCase, setSelectedCase] = useState<string>("");
    const [searchTerm, setSearchTerm] = useState("");
    const [sortField, setSortField] = useState("timestamp");
    const [sortOrder, setSortOrder] = useState<"asc" | "desc">("desc");
    const [page, setPage] = useState(1);
    const pageSize = 20;

    // Permissions
    const canViewEvidence = userRole === "officer" || userRole === "admin";
    const canViewWitnesses = userRole === "judge" || userRole === "admin";
    const canViewScenarios = true;

    // Filtering, sorting, pagination
    function processData<T extends { case_id?: string }>(arr: T[]) {
        let filtered = selectedCase ? arr.filter(i => i.case_id === selectedCase) : arr;
        filtered = filtered.filter(i =>
            Object.values(i).some(val =>
                typeof val === "string" && val.toLowerCase().includes(searchTerm.toLowerCase())
            )
        );
        filtered = _.orderBy(filtered, [sortField], [sortOrder]);
        return filtered.slice((page - 1) * pageSize, page * pageSize);
    }

    const filteredEvidence = processData<Evidence>(evidence);
    const filteredWitnesses = processData<Witness>(witnesses);
    const filteredScenarios = processData<Scenario>(scenarios);

    // Export function
    function exportCaseData() {
        const caseData = cases.find(c => c.id === selectedCase);
        const evidenceData = evidence.filter(e => e.case_id === selectedCase);
        const witnessData = witnesses.filter(w => w.case_id === selectedCase);
        const scenarioData = scenarios.filter(s => s.case_id === selectedCase);
        const exportObj = { case: caseData, evidence: evidenceData, witnesses: witnessData, scenarios: scenarioData };
        const blob = new Blob([JSON.stringify(exportObj, null, 2)], { type: "application/json" });
        const url = URL.createObjectURL(blob);
        const a = document.createElement("a");
        a.href = url;
        a.download = `case_${selectedCase}.json`;
        a.click();
        URL.revokeObjectURL(url);
    }

    if (loading) return <div>Loading MDT data...</div>;
    if (error) return <div>Error: {error}</div>;

    return (
        <div>
            <h1>Mobile Data Terminal</h1>
            <div>
                <label>Select Case:</label>
                <select onChange={e => setSelectedCase(e.target.value)} value={selectedCase}>
                    <option value="">All Cases</option>
                    {cases.map(c => (
                        <option key={c.id} value={c.id}>{c.title || c.id}</option>
                    ))}
                </select>
                <input
                    type="text"
                    placeholder="Search..."
                    value={searchTerm}
                    onChange={e => setSearchTerm(e.target.value)}
                    style={{ marginLeft: 10 }}
                />
                <label style={{ marginLeft: 10 }}>Sort by:</label>
                <select onChange={e => setSortField(e.target.value)} value={sortField}>
                    <option value="timestamp">Timestamp</option>
                    <option value="type">Type</option>
                    <option value="collected_by">Officer</option>
                </select>
                <button onClick={() => setSortOrder(sortOrder === "asc" ? "desc" : "asc")}>
                    {sortOrder === "asc" ? "↑" : "↓"}
                </button>
                <button onClick={exportCaseData} disabled={!selectedCase}>Export Case Data</button>
            </div>
            <div>
                <button disabled={page === 1} onClick={() => setPage(page - 1)}>Prev</button>
                <span> Page {page} </span>
                <button onClick={() => setPage(page + 1)}>Next</button>
            </div>
            {canViewEvidence && (
                <>
                    <h2>Evidence Locker</h2>
                    <table>
                        <thead>
                            <tr>
                                <th>Type</th>
                                <th>Description</th>
                                <th>Location</th>
                                <th>Officer</th>
                                <th>Case</th>
                                <th>Timestamp</th>
                                {userRole === "admin" && <th>Actions</th>}
                            </tr>
                        </thead>
                        <tbody>
                            {filteredEvidence.map(item => (
                                <tr key={item.id}>
                                    <td>{item.type}</td>
                                    <td>{item.description}</td>
                                    <td>{item.coords}</td>
                                    <td>{item.collected_by}</td>
                                    <td>{item.case_id}</td>
                                    <td>{item.timestamp ? new Date(item.timestamp * 1000).toLocaleString() : ""}</td>
                                    {userRole === "admin" && <td><button>Edit</button></td>}
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </>
            )}
            {canViewWitnesses && (
                <>
                    <h2>Witness Statements</h2>
                    <table>
                        <thead>
                            <tr>
                                <th>NPC ID</th>
                                <th>Statement</th>
                                <th>Case</th>
                                <th>Timestamp</th>
                                {userRole === "admin" && <th>Actions</th>}
                            </tr>
                        </thead>
                        <tbody>
                            {filteredWitnesses.map(w => (
                                <tr key={w.id}>
                                    <td>{w.npc_id}</td>
                                    <td>{w.statement}</td>
                                    <td>{w.case_id}</td>
                                    <td>{w.timestamp ? new Date(w.timestamp * 1000).toLocaleString() : ""}</td>
                                    {userRole === "admin" && <td><button>Edit</button></td>}
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </>
            )}
            {canViewScenarios && (
                <>
                    <h2>Active Scenarios</h2>
                    <table>
                        <thead>
                            <tr>
                                <th>Type</th>
                                <th>Details</th>
                                <th>Location</th>
                                <th>Timestamp</th>
                            </tr>
                        </thead>
                        <tbody>
                            {filteredScenarios.map(s => (
                                <tr key={s.id}>
                                    <td>{s.type}</td>
                                    <td>{s.details}</td>
                                    <td>{s.coords}</td>
                                    <td>{s.timestamp ? new Date(s.timestamp * 1000).toLocaleString() : ""}</td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </>
            )}
        </div>
    );
}