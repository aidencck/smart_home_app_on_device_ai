import React, { useState, useEffect, useCallback } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { HeartPulse, BedDouble, Tv, Thermometer, Waves, Volume2, Sun, MoonStar, VolumeX, Layers, Lightbulb } from 'lucide-react';

// --- Types & Data ---

type Phase = 1 | 2 | 3;

interface DeviceState {
  ring: {
    hr: number;
    stage: string;
    hrv: string;
    spo2: number;
    temp: number;
    respiration: number;
    movement: string;
  };
  bed: {
    angle: number;
    vibration: string;
    temp: string;
    support_level: string;
  };
  tv: {
    visual: string;
    audio: string;
    brightness: number;
    ambient_light: string;
  };
}

const PHASES = [
  { id: 1, name: '入睡准备与助眠', desc: '心率平稳，开启助眠资产，床体零重力' },
  { id: 2, name: '深睡沉浸与动态守护', desc: '进入深睡，环境全黑，动态温控介入' },
  { id: 3, name: '顺应节律的无感唤醒', desc: '浅睡期检测，日出光晕与触觉轻柔唤醒' },
];

const MOCK_INITIAL_DATA = {
  sleep_stage: 'LIGHT_SLEEP',
  devices: {
    bed: {
      id: 'bed_1',
      vector_clock: 1,
      state: {
        angle: 15,
        vibration: '轻微背部舒缓',
        temp: '智能恒温 (26°C)',
        support_level: '柔软包裹 (释压)'
      }
    },
    ring: {
      id: 'ring_1',
      vector_clock: 1,
      state: { hr: 68, stage: '浅睡眠 (入睡期)', hrv: '45ms (正常)', spo2: 98, temp: 36.6, respiration: 16, movement: '轻微调整姿势' }
    },
    tv: {
      id: 'tv_1',
      vector_clock: 1,
      state: { visual: '篝火/雨滴 Shader', audio: 'ASMR 白噪音', brightness: 40, ambient_light: '暖橘色呼吸 (同步心率)' }
    }
  }
};

const getPhaseFromStage = (stage: string): Phase => {
  if (stage === 'DEEP_SLEEP') return 2;
  if (stage === 'AWAKE') return 3;
  return 1;
};

// --- Components ---

export default function App() {
  const [homeData, setHomeData] = useState(MOCK_INITIAL_DATA);
  const [loading, setLoading] = useState(true);

  const fetchHomeSummary = useCallback(async () => {
    try {
      const res = await fetch('http://localhost:8000/v1/home/summary');
      if (res.ok) {
        const data = await res.json();
        setHomeData(data);
      } else {
        throw new Error('Server returned ' + res.status);
      }
    } catch (err) {
      console.warn("Using mock data, failed to fetch real state:", err);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchHomeSummary();
    // Optional: poll every 5s for real-time updates
    const interval = setInterval(fetchHomeSummary, 5000);
    return () => clearInterval(interval);
  }, [fetchHomeSummary]);

  const handleBedAngleChange = async (newAngle: number) => {
    const bedId = homeData.devices.bed.id;
    const currentClock = homeData.devices.bed.vector_clock;
    
    try {
      const res = await fetch(`http://localhost:8000/v1/devices/${bedId}/state`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ 
          state: { angle: newAngle }, 
          vector_clock: currentClock 
        }),
      });

      if (res.status === 409) {
        alert("Conflict detected (409): 设备状态已被其他终端修改。正在同步最新状态...");
        fetchHomeSummary(); // Revert
      } else if (res.ok) {
        fetchHomeSummary(); // Update clock and state
      } else {
        throw new Error("Failed to update");
      }
    } catch (err) {
      console.error("Update failed", err);
      // alert("请求失败，请检查网络或后端服务状态。");
      // 模拟更新成功
      setHomeData(prev => ({
        ...prev,
        devices: {
          ...prev.devices,
          bed: {
            ...prev.devices.bed,
            vector_clock: prev.devices.bed.vector_clock + 1,
            state: { ...prev.devices.bed.state, angle: newAngle }
          }
        }
      }));
    }
  };

  const setSimulatedPhase = (phaseId: number) => {
    const stageMap: Record<number, string> = {
      1: 'LIGHT_SLEEP',
      2: 'DEEP_SLEEP',
      3: 'AWAKE'
    };
    
    setHomeData(prev => ({
      ...prev,
      sleep_stage: stageMap[phaseId],
      devices: {
        ...prev.devices,
        bed: {
          ...prev.devices.bed,
          state: { 
            ...prev.devices.bed.state, 
            angle: phaseId === 2 ? 0 : phaseId === 1 ? 15 : 10 
          }
        },
        tv: {
          ...prev.devices.tv,
          state: {
            ...prev.devices.tv.state,
            visual: phaseId === 2 ? '全黑息屏' : phaseId === 1 ? '篝火/雨滴 Shader' : '日出渐变光晕',
            brightness: phaseId === 2 ? 0 : phaseId === 1 ? 40 : 70
          }
        }
      }
    }));
  };

  const phase = getPhaseFromStage(homeData.sleep_stage);
  const state = {
    ring: homeData.devices.ring.state,
    bed: homeData.devices.bed.state,
    tv: homeData.devices.tv.state,
  };

  return (
    <div className="min-h-screen bg-slate-950 text-slate-200 font-sans selection:bg-indigo-500/30 flex flex-col overflow-y-auto">
      {/* Header & Phase Selector */}
      <header className="px-8 py-6 border-b border-slate-800/60 bg-slate-900/80 backdrop-blur-xl sticky top-0 z-50">
        <div className="max-w-7xl mx-auto">
          <h1 className="text-2xl font-semibold text-white flex items-center gap-3">
            <MoonStar className="text-indigo-400" />
            卧室无感智能联动演示 (Zero-UI)
          </h1>
          <p className="text-slate-400 mt-2 text-sm">
            基于智能戒指实时生理数据的多设备无缝协同体验
          </p>
          
          <div className="flex gap-4 mt-6 relative">
            {PHASES.map((p) => (
              <button
                key={p.id}
                onClick={() => setSimulatedPhase(p.id)}
                className={`flex-1 relative p-4 rounded-xl text-left transition-all duration-300 ${
                  phase === p.id 
                    ? 'bg-indigo-600/20 border-indigo-500/50 shadow-[0_0_15px_rgba(99,102,241,0.15)]' 
                    : 'bg-slate-800/30 border-slate-700/50 hover:bg-slate-800/50'
                } border`}
              >
                {phase === p.id && (
                  <motion.div
                    layoutId="activePhase"
                    className="absolute inset-0 rounded-xl border-2 border-indigo-400"
                    initial={false}
                    transition={{ type: "spring", stiffness: 300, damping: 30 }}
                  />
                )}
                <div className="relative z-10">
                  <div className="text-xs font-mono text-indigo-400 mb-1">PHASE {p.id}</div>
                  <div className={`font-medium ${phase === p.id ? 'text-white' : 'text-slate-300'}`}>
                    {p.name}
                  </div>
                  <div className="text-xs text-slate-500 mt-1 line-clamp-1">{p.desc}</div>
                </div>
              </button>
            ))}
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="flex-1 max-w-7xl mx-auto w-full p-6 flex flex-col gap-10 pb-20">
        
        {/* ========================================================= */}
        {/* 真实的房间模拟视图 (Real Room Simulation)                     */}
        {/* ========================================================= */}
        <div className="relative w-full h-[450px] bg-slate-900 rounded-3xl overflow-hidden border border-slate-800 shadow-2xl flex-shrink-0 flex items-end justify-center">
          
          {/* 全局光影滤镜 (Global Lighting Overlay) */}
          <motion.div 
            className="absolute inset-0 z-40 pointer-events-none mix-blend-overlay"
            animate={{
              backgroundColor: phase === 1 ? 'rgba(67, 56, 202, 0.4)' : phase === 2 ? 'rgba(0, 0, 0, 0.8)' : 'rgba(249, 115, 22, 0.2)'
            }}
            transition={{ duration: 1.5 }}
          />

          {/* 背景墙与窗户 (Back Wall & Window) */}
          <div className="absolute inset-0 bg-slate-800/50 flex items-center justify-center">
            {/* 窗户 */}
            <div className="relative w-72 h-56 rounded-t-full border-[10px] border-slate-800 overflow-hidden mb-16 shadow-[inset_0_0_30px_rgba(0,0,0,0.8)]">
              {/* 窗外天空颜色 */}
              <motion.div 
                className="w-full h-full"
                animate={{
                  background: phase === 1 ? 'linear-gradient(to bottom, #1e1b4b, #0f172a)' : 
                              phase === 2 ? 'linear-gradient(to bottom, #020617, #000000)' : 
                              'linear-gradient(to bottom, #ea580c, #fde047)'
                }}
                transition={{ duration: 2 }}
              />
              {/* 月亮 / 太阳 */}
              <motion.div 
                className="absolute left-1/2 -translate-x-1/2 w-14 h-14 rounded-full"
                animate={{
                  top: phase === 2 ? '70%' : '20%',
                  backgroundColor: phase === 1 ? '#e2e8f0' : phase === 2 ? '#334155' : '#fef08a',
                  boxShadow: phase === 3 ? '0 0 60px #fef08a, 0 0 100px #ea580c' : phase === 1 ? '0 0 20px #e2e8f0' : '0 0 0px transparent',
                }}
                transition={{ duration: 2, type: 'spring' }}
              />
            </div>
          </div>

          {/* 地板 (Floor with perspective) */}
          <div 
            className="absolute bottom-0 w-full h-48 bg-slate-800 border-t border-slate-700" 
            style={{ transform: 'perspective(800px) rotateX(70deg)', transformOrigin: 'bottom' }}
          >
             {/* 地板网格 */}
             <div className="w-full h-full opacity-20" style={{ backgroundImage: 'linear-gradient(#94a3b8 2px, transparent 2px), linear-gradient(90deg, #94a3b8 2px, transparent 2px)', backgroundSize: '60px 60px' }} />
          </div>

          {/* 智能电视 (挂在右侧墙面, 侧视图) */}
          <div className="absolute right-24 top-28 w-8 h-48 bg-slate-800 rounded-l-xl border-y-4 border-l-4 border-slate-700 flex items-center justify-start z-20 shadow-2xl">
            {/* 电视屏幕侧面发光区域 */}
            <motion.div 
              className="w-2 h-44 rounded-l-sm"
              animate={{
                backgroundColor: phase === 1 ? '#fb923c' : phase === 2 ? '#0f172a' : '#fde047',
                boxShadow: phase === 1 ? '-20px 0 60px 15px rgba(251, 146, 60, 0.5)' : 
                           phase === 2 ? '0 0 0px transparent' : 
                           '-40px 0 80px 20px rgba(253, 224, 71, 0.7)'
              }}
              transition={{ duration: 1.5 }}
            />
          </div>

          {/* 电视光晕投射到房间 (TV Light Cast) */}
          <motion.div 
            className="absolute right-24 top-1/2 -translate-y-1/2 w-[600px] h-[400px] rounded-full pointer-events-none mix-blend-screen z-10"
            animate={{
              background: phase === 1 ? 'radial-gradient(circle at right, rgba(251, 146, 60, 0.15) 0%, transparent 70%)' : 
                          phase === 2 ? 'radial-gradient(circle at right, rgba(0, 0, 0, 0) 0%, transparent 70%)' : 
                          'radial-gradient(circle at right, rgba(253, 224, 71, 0.25) 0%, transparent 70%)'
            }}
            transition={{ duration: 1.5 }}
          />

          {/* 智能床 (位于房间中左侧) */}
          <div className="absolute bottom-20 left-1/2 -translate-x-[60%] w-[480px] h-36 z-30 flex items-end">
            
            {/* 床架底座 */}
            <div className="absolute bottom-0 left-0 w-full h-12 bg-slate-800 rounded-xl border-b-[12px] border-slate-900 shadow-[0_20px_30px_rgba(0,0,0,0.5)]" />
            
            {/* 床腿 */}
            <div className="absolute -bottom-4 left-12 w-5 h-4 bg-slate-700 rounded-b-md" />
            <div className="absolute -bottom-4 right-12 w-5 h-4 bg-slate-700 rounded-b-md" />

            {/* 床垫下半部 (固定平躺) */}
            <div className="absolute bottom-12 right-0 w-[280px] h-14 bg-slate-300 rounded-r-xl border-b-4 border-slate-400 flex items-end">
              {/* 盖在腿上的被子 */}
              <div className="w-full h-16 bg-indigo-800 rounded-tr-2xl rounded-br-lg border-t-4 border-indigo-600 shadow-inner" />
              
              {/* 用户的手与智能戒指 (放在被子上) */}
              <div className="absolute top-[-16px] left-16 w-12 h-8 bg-orange-200/90 rounded-full z-40 flex items-center justify-center shadow-lg border border-orange-300/50">
                {/* 智能戒指发光点 */}
                <motion.div 
                  className="w-3 h-3 bg-rose-500 rounded-full"
                  animate={{ scale: [1, 1.8, 1], opacity: [1, 0.4, 1] }}
                  transition={{ repeat: Infinity, duration: 60 / state.ring.hr, ease: "easeInOut" }}
                  style={{ boxShadow: '0 0 15px #f43f5e' }}
                />
              </div>
            </div>

            {/* 床垫上半部 (根据 phase 改变仰角) */}
            <motion.div 
              className="absolute bottom-12 left-0 w-[200px] h-14 bg-slate-300 rounded-l-xl border-b-4 border-slate-400 flex items-end"
              style={{ originX: 1, originY: 1 }} // 铰链在右下角
              animate={{ rotate: state.bed.angle }}
              transition={{ type: "spring", damping: 20, stiffness: 60 }}
            >
              {/* 枕头 */}
              <div className="absolute bottom-14 left-4 w-28 h-10 bg-slate-100 rounded-2xl shadow-md border-b-2 border-slate-200" />
              
              {/* 用户的头部 */}
              <div className="absolute bottom-12 left-14 w-16 h-16 bg-slate-700 rounded-full border-4 border-slate-800" />
              
              {/* 盖在胸前的被子 */}
              <div className="w-full h-16 bg-indigo-800 rounded-tl-2xl rounded-bl-lg border-t-4 border-indigo-600 shadow-inner" />
            </motion.div>

            {/* 智能床体震动动画指示 */}
            <AnimatePresence>
              {state.bed.vibration !== '关闭' && (
                <motion.div 
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  exit={{ opacity: 0 }}
                  className="absolute -bottom-10 left-1/2 -translate-x-1/2 flex gap-4"
                >
                  {[1,2,3,4,5,6,7].map(i => (
                    <motion.div 
                      key={i}
                      className="w-2 h-1.5 bg-cyan-400/60 rounded-full blur-[1px]"
                      animate={{ y: [0, -10, 0], scale: [1, 1.5, 1], opacity: [0.3, 0.8, 0.3] }}
                      transition={{ repeat: Infinity, duration: state.bed.angle === 15 ? 1.5 : 0.5, delay: i * 0.1 }}
                    />
                  ))}
                </motion.div>
              )}
            </AnimatePresence>
          </div>

          {/* 悬浮在房间内的状态标牌 (HUD) */}
          <div className="absolute top-6 left-6 flex flex-col gap-3 z-50">
            <div className="bg-slate-900/60 backdrop-blur-md px-4 py-2.5 rounded-full border border-slate-700 flex items-center gap-3 text-sm text-white shadow-xl">
              <Thermometer size={18} className={phase === 2 ? 'text-blue-400' : 'text-orange-400'} />
              <span>环境温控: <span className="font-medium tracking-wide">{state.bed.temp}</span></span>
            </div>
            <div className="bg-slate-900/60 backdrop-blur-md px-4 py-2.5 rounded-full border border-slate-700 flex items-center gap-3 text-sm text-white shadow-xl">
              <Volume2 size={18} className={phase === 2 ? 'text-slate-500' : 'text-emerald-400'} />
              <span>全景声场: <span className="font-medium tracking-wide">{state.tv.audio}</span></span>
            </div>
          </div>
        </div>

        {/* ========================================================= */}
        {/* 底部详细数据控制台 (Detailed Data Dashboard)                */}
        {/* ========================================================= */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          
          {/* Device 1: Smart Ring */}
          <div className="bg-slate-900/60 border border-slate-800 rounded-2xl p-6 relative overflow-hidden flex flex-col">
            <div className="absolute top-0 right-0 p-32 bg-rose-500/5 rounded-full blur-3xl -mr-16 -mt-16"></div>
            <div className="flex items-center gap-3 mb-6">
              <div className="p-2 bg-rose-500/20 rounded-lg text-rose-400">
                <HeartPulse size={20} />
              </div>
              <h2 className="text-base font-medium text-white">智能戒指 (感知核心)</h2>
            </div>
            <div className="flex-1 flex flex-col gap-6">
              <div className="text-center">
                <motion.div 
                  key={phase}
                  initial={{ scale: 0.8, opacity: 0 }}
                  animate={{ scale: 1, opacity: 1 }}
                  className="inline-flex items-end justify-center gap-2 text-4xl font-light text-rose-400 mb-1"
                >
                  {state.ring.hr}
                  <span className="text-base text-rose-400/60 mb-1 font-mono">BPM</span>
                </motion.div>
                <div className="text-xs text-slate-400">实时心率监测</div>
              </div>
              <div className="grid grid-cols-2 gap-2">
                <div className="bg-slate-800/40 rounded-lg p-2.5">
                  <div className="text-[10px] text-slate-500 mb-1">睡眠阶段</div>
                  <div className="text-xs font-medium text-indigo-300 truncate">{state.ring.stage}</div>
                </div>
                <div className="bg-slate-800/40 rounded-lg p-2.5">
                  <div className="text-[10px] text-slate-500 mb-1">HRV (心率变异性)</div>
                  <div className="text-xs font-medium text-teal-300 truncate">{state.ring.hrv}</div>
                </div>
                <div className="bg-slate-800/40 rounded-lg p-2.5">
                  <div className="text-[10px] text-slate-500 mb-1">SpO2 (血氧饱和度)</div>
                  <div className="text-xs font-medium text-blue-300 truncate">{state.ring.spo2}%</div>
                </div>
                <div className="bg-slate-800/40 rounded-lg p-2.5">
                  <div className="text-[10px] text-slate-500 mb-1">体表温度</div>
                  <div className="text-xs font-medium text-orange-300 truncate">{state.ring.temp}°C</div>
                </div>
                <div className="bg-slate-800/40 rounded-lg p-2.5">
                  <div className="text-[10px] text-slate-500 mb-1">呼吸频率</div>
                  <div className="text-xs font-medium text-sky-300 truncate">{state.ring.respiration} 次/分</div>
                </div>
                <div className="bg-slate-800/40 rounded-lg p-2.5">
                  <div className="text-[10px] text-slate-500 mb-1">体动状态</div>
                  <div className="text-xs font-medium text-purple-300 truncate">{state.ring.movement}</div>
                </div>
              </div>
            </div>
          </div>

          {/* Device 2: Smart Bed */}
          <div className="bg-slate-900/60 border border-slate-800 rounded-2xl p-6 relative overflow-hidden flex flex-col">
            <div className="absolute top-0 right-0 p-32 bg-cyan-500/5 rounded-full blur-3xl -mr-16 -mt-16"></div>
            <div className="flex items-center gap-3 mb-6">
              <div className="p-2 bg-cyan-500/20 rounded-lg text-cyan-400">
                <BedDouble size={20} />
              </div>
              <h2 className="text-base font-medium text-white">智能床 (执行终端)</h2>
            </div>
            <div className="flex-1 flex flex-col justify-center gap-4">
              
              {/* 可交互的床头仰角滑块 */}
              <div className="bg-slate-800/40 rounded-xl p-4 flex flex-col gap-3">
                <div className="flex items-center justify-between">
                  <div>
                    <div className="text-xs text-slate-500 mb-1">床头仰角控制</div>
                    <div className="text-sm font-medium text-slate-200">{state.bed.angle}°</div>
                  </div>
                  <div className="text-xs font-mono text-cyan-400 bg-cyan-500/10 px-2 py-1 rounded">
                    {state.bed.angle === 15 ? '零重力/阅读' : state.bed.angle === 0 ? '平躺深睡' : '自定义'}
                  </div>
                </div>
                <input
                  type="range"
                  min="0"
                  max="60"
                  value={state.bed.angle}
                  disabled={homeData.sleep_stage === 'DEEP_SLEEP'}
                  onChange={(e) => {
                    const newAngle = Number(e.target.value);
                    setHomeData(prev => ({
                      ...prev,
                      devices: {
                        ...prev.devices,
                        bed: {
                          ...prev.devices.bed,
                          state: { ...prev.devices.bed.state, angle: newAngle }
                        }
                      }
                    }));
                  }}
                  onMouseUp={(e) => handleBedAngleChange(Number((e.target as HTMLInputElement).value))}
                  onTouchEnd={(e) => handleBedAngleChange(Number((e.target as HTMLInputElement).value))}
                  className={`w-full h-2 rounded-lg appearance-none cursor-pointer ${
                    homeData.sleep_stage === 'DEEP_SLEEP' ? 'bg-slate-700' : 'bg-cyan-900/50 accent-cyan-400'
                  }`}
                />
                {homeData.sleep_stage === 'DEEP_SLEEP' && (
                  <div className="text-[10px] text-rose-400 text-right">
                    深睡期间已锁定，不可调节
                  </div>
                )}
              </div>

              <div className="bg-slate-800/40 rounded-xl p-4 flex items-center gap-4">
                <Waves className="text-indigo-400" size={18} />
                <div>
                  <div className="text-xs text-slate-500 mb-0.5">床体震动反馈</div>
                  <div className="text-sm font-medium text-slate-200">{state.bed.vibration}</div>
                </div>
              </div>
              <div className="bg-slate-800/40 rounded-xl p-4 flex items-center gap-4">
                <Thermometer className="text-orange-400" size={18} />
                <div>
                  <div className="text-xs text-slate-500 mb-0.5">床垫恒温系统</div>
                  <div className="text-sm font-medium text-slate-200">{state.bed.temp}</div>
                </div>
              </div>
              <div className="bg-slate-800/40 rounded-xl p-4 flex items-center gap-4">
                <Layers className="text-purple-400" size={18} />
                <div>
                  <div className="text-xs text-slate-500 mb-0.5">分区支撑度</div>
                  <div className="text-sm font-medium text-slate-200">{state.bed.support_level}</div>
                </div>
              </div>
            </div>
          </div>

          {/* Device 3: Smart TV */}
          <div className="bg-slate-900/60 border border-slate-800 rounded-2xl p-6 relative overflow-hidden flex flex-col">
            <div className="absolute top-0 right-0 p-32 bg-amber-500/5 rounded-full blur-3xl -mr-16 -mt-16"></div>
            <div className="flex items-center gap-3 mb-6">
              <div className="p-2 bg-amber-500/20 rounded-lg text-amber-400">
                <Tv size={20} />
              </div>
              <h2 className="text-base font-medium text-white">智能电视 (视听环境)</h2>
            </div>
            <div className="flex-1 flex flex-col justify-center gap-4">
              <div className="bg-slate-800/40 rounded-xl p-4 flex items-center gap-4">
                <Sun className="text-amber-400" size={18} />
                <div className="flex-1">
                  <div className="text-xs text-slate-500 mb-0.5">屏幕画面与光感</div>
                  <div className="text-sm font-medium text-slate-200">{state.tv.visual}</div>
                </div>
                <div className="text-xs font-mono text-amber-400 bg-amber-500/10 px-2 py-1 rounded">
                  亮度 {state.tv.brightness}%
                </div>
              </div>
              <div className="bg-slate-800/40 rounded-xl p-4 flex items-center gap-4">
                {phase === 2 ? <VolumeX className="text-slate-500" size={18} /> : <Volume2 className="text-emerald-400" size={18} />}
                <div>
                  <div className="text-xs text-slate-500 mb-0.5">音响系统</div>
                  <div className="text-sm font-medium text-slate-200">{state.tv.audio}</div>
                </div>
              </div>
              <div className="bg-slate-800/40 rounded-xl p-4 flex items-center gap-4">
                <Lightbulb className="text-rose-400" size={18} />
                <div>
                  <div className="text-xs text-slate-500 mb-0.5">背光氛围灯</div>
                  <div className="text-sm font-medium text-slate-200">{state.tv.ambient_light}</div>
                </div>
              </div>
            </div>
          </div>

        </div>

      </main>

      <footer className="text-center p-6 text-sm text-slate-600">
        无感智能体系 (Zero-UI) · 真实房间联动侧写
      </footer>
    </div>
  );
}