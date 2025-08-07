import { useState, useEffect } from "react";
import _ from "lodash";

export interface Evidence { id: string; type: string; description: string; coords: string; collected_by: string; case_id: string; timestamp?: number; }
export interface Witness { id: string; npc_id: number; statement: string; case_id: string; timestamp?: number; }
export interface Scenario { id: string; type: string; details: string; coords: string; case_id: string; timestamp?: number; }
export interface Case { id: string; title: string; description: string; status: string; created_by: string; created_at?: number; }

export function useMDTData() {
    const [cases, setCases] = useState<Case[]>([]);
    const [evidence, setEvidence] = useState<Evidence[]>([]);
    const [witnesses, setWitnesses] = useState<Witness[]>([]);
    const [scenarios, setScenarios] = useState<Scenario[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        async function fetchAll() {
            setLoading(true);
            setError(null);
            try {
                const [casesRes, evidenceRes, witnessesRes, scenariosRes] = await Promise.all([
                    window.fetchNui("mdt:getCases"),
                    window.fetchNui("mdt:getEvidence"),
                    window.fetchNui("mdt:getWitnesses"),
                    window.fetchNui("mdt:getScenarios"),
                ]);
                if (!casesRes.success || !evidenceRes.success || !witnessesRes.success || !scenariosRes.success) {
                    throw new Error("Failed to fetch some MDT data.");
                }
                setCases(casesRes.data);
                setEvidence(evidenceRes.data);
                setWitnesses(witnessesRes.data);
                setScenarios(scenariosRes.data);
            } catch (err) {
                setError(err.message || "Unknown error");
            }
            setLoading(false);
        }
        fetchAll();
    }, []);

    return { cases, evidence, witnesses, scenarios, loading, error };
}