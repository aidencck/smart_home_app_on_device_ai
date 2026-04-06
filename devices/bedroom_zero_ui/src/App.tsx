import React, { useState, useEffect, useCallback } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { HeartPulse, BedDouble, Tv, Thermometer, Waves, Volume2, Sun, MoonStar, VolumeX, Layers, Lightbulb, Lock } from 'lucide-react';
import { Toaster, toast } from 'sonner';

// --- Types & Data ---

type Phase = 1 | 2 | 3;

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
  const [shakeLock, setShakeLock] = useState(false);
  const [originalBedAngle, setOriginalBedAngle] = useState(MOCK_INITIAL_DATA.devices.bed.state.angle);

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
    }
  }, []);

  useEffect(() => {
    fetchHomeSummary();
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
        toast.error("状态已被其他终端/AI 更改，已同步最新状态", {
          description: "冲突检测 (409)",
          icon: "🔄"
        });
        setHomeData(prev => ({
          ...prev,
          devices: {
            ...prev.devices,
            bed: {
              ...prev.devices.bed,
              state: { ...prev.devices.bed.state, angle: originalBedAngle }
            }
          }
        }));
        fetchHomeSummary(); 
      } else if (res.ok) {
        fetchHomeSummary(); 
      } else {
        throw new Error("Failed to update");
      }
    } catch (err) {
      console.error("Update failed", err);
      toast.error("边缘中枢连接断开，已恢复缓存状态", { icon: "⚠️" });
      setHomeData(prev => ({
        ...prev,
        devices: {
          ...prev.devices,
          bed: {
            ...prev.devices.bed,
            state: { ...prev.devices.bed.state, angle: originalBedAngle }
          }
        }
      }));
    }
  };

  const handleSliderInteraction = (e: React.MouseEvent | React.TouchEvent) => {
    if (homeData.sleep_stage === 'DEEP_SLEEP') {
      e.preventDefault();
      e.stopPropagation();
      setShakeLock(true);
      toast.error('深睡期已物理锁定，防止惊醒', { icon: '🔒' });
      setTimeout(() => setShakeLock(false), 500);
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
        ring: {
          ...prev.devices.ring,
          state: {
            ...prev.devices.ring.state,
            stage: phaseId === 1 ? '浅睡眠 (入睡期)' : phaseId === 2 ? '深度睡眠' : '清醒 (快速眼动)',
            hr: phaseId === 1 ? 68 : phaseId === 2 ? 55 : 75,
            hrv: phaseId === 1 ? '45ms (正常)' : phaseId === 2 ? '65ms (极佳)' : '35ms (偏低)'
          }
        },
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
    <>
      <Toaster theme="dark" position="top-center" />
      
      {/* 动态环境视界 (Ambient Hero Section) */}
      <motion.div 
        className="fixed inset-0 z-0"
        animate={{
          background: homeData.sleep_stage === 'AWAKE' 
            ? 'linear-gradient(135deg, #1e3a8a 0%, #ea580c 100%)' 
            : homeData.sleep_stage === 'LIGHT_SLEEP'
            ? 'linear-gradient(135deg, #1e1b4b 0%, #312e81 100%)'
            : 'linear-gradient(135deg, #020617 0%, #000000 100%)'
        }}
        transition={{ duration: 1.5, ease: "easeInOut" }}
      />

      <div className="relative z-10 h-screen text-slate-200 font-sans selection:bg-indigo-500/30 flex flex-col overflow-hidden">
        {/* Header & Phase Selector */}
        <header className="px-6 py-4 border-b border-white/10 bg-black/20 backdrop-blur-2xl sticky top-0 z-50 flex-shrink-0">
          <div className="max-w-7xl mx-auto flex flex-col md:flex-row md:items-center justify-between gap-4">
            <div>
              <h1 className="text-xl font-semibold text-white flex items-center gap-3 drop-shadow-md">
                <MoonStar className="text-indigo-400" />
                卧室无感智能联动 (Zero-UI)
              </h1>
              <p className="text-slate-300 mt-1 text-xs drop-shadow">
                基于智能戒指实时生理数据的多设备无缝协同体验
              </p>
            </div>
            
            <div className="flex gap-2">
              {PHASES.map((p) => (
                <button
                  key={p.id}
                  onClick={() => setSimulatedPhase(p.id)}
                  className={`relative p-2 px-4 rounded-xl text-left transition-all duration-300 ${
                    phase === p.id 
                      ? 'bg-white/20 border-white/40 shadow-[0_0_20px_rgba(255,255,255,0.1)]' 
                      : 'bg-black/20 border-white/10 hover:bg-white/10'
                  } border backdrop-blur-md`}
                >
                  {phase === p.id && (
                    <motion.div
                      layoutId="activePhase"
                      className="absolute inset-0 rounded-xl border-2 border-white/50"
                      initial={false}
                      transition={{ type: "spring", stiffness: 300, damping: 30 }}
                    />
                  )}
                  <div className="relative z-10 flex flex-col">
                    <div className="text-[10px] font-mono text-indigo-300 drop-shadow">PHASE {p.id}</div>
                    <div className={`text-sm font-medium ${phase === p.id ? 'text-white' : 'text-slate-300'} drop-shadow whitespace-nowrap`}>
                      {p.name}
                    </div>
                  </div>
                </button>
              ))}
            </div>
          </div>
        </header>

        {/* Main Content */}
        <main className="flex-1 min-h-0 max-w-7xl mx-auto w-full p-4 flex flex-col gap-4 overflow-y-auto">
          
          {/* ========================================================= */}
          {/* 真实的房间模拟视图 (Real Room Simulation)                     */}
          {/* ========================================================= */}
          <div className="relative w-full flex-1 min-h-[25vh] bg-black/40 backdrop-blur-3xl rounded-[2rem] overflow-hidden border border-white/10 shadow-2xl flex items-end justify-center">
            
            {/* 全局光影滤镜 (Global Lighting Overlay) */}
            <motion.div 
              className="absolute inset-0 z-40 pointer-events-none mix-blend-overlay"
              animate={{
                backgroundColor: phase === 1 ? 'rgba(67, 56, 202, 0.4)' : phase === 2 ? 'rgba(0, 0, 0, 0.8)' : 'rgba(249, 115, 22, 0.2)'
              }}
              transition={{ duration: 1.5 }}
            />

            {/* 背景墙与窗户 (Back Wall & Window) */}
            <div className="absolute inset-0 flex items-center justify-center">
              {/* 窗户 */}
              <div className="relative w-72 h-56 rounded-t-full border-[10px] border-black/40 overflow-hidden mb-16 shadow-[inset_0_0_30px_rgba(0,0,0,0.8)]">
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
              className="absolute bottom-0 w-full h-48 bg-black/40 border-t border-white/5" 
              style={{ transform: 'perspective(800px) rotateX(70deg)', transformOrigin: 'bottom' }}
            >
               {/* 地板网格 */}
               <div className="w-full h-full opacity-10" style={{ backgroundImage: 'linear-gradient(#fff 1px, transparent 1px), linear-gradient(90deg, #fff 1px, transparent 1px)', backgroundSize: '60px 60px' }} />
            </div>

            {/* 智能电视 (挂在右侧墙面, 侧视图) */}
            <div className="absolute right-24 top-28 w-8 h-48 bg-black/60 rounded-l-xl border-y border-l border-white/10 flex items-center justify-start z-20 shadow-2xl backdrop-blur-xl">
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
              <div className="absolute bottom-0 left-0 w-full h-12 bg-black/60 rounded-xl border-b-[8px] border-black/80 shadow-[0_20px_40px_rgba(0,0,0,0.8)] backdrop-blur-xl" />
              
              {/* 床垫下半部 (固定平躺) */}
              <div className="absolute bottom-12 right-0 w-[280px] h-14 bg-slate-200/90 rounded-r-xl border-b-2 border-slate-300/50 flex items-end">
                {/* 盖在腿上的被子 */}
                <div className="w-full h-16 bg-indigo-900/90 rounded-tr-2xl rounded-br-lg border-t-2 border-indigo-700/50 shadow-inner" />
                
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
                className="absolute bottom-12 left-0 w-[200px] h-14 bg-slate-200/90 rounded-l-xl border-b-2 border-slate-300/50 flex items-end"
                style={{ originX: 1, originY: 1 }} // 铰链在右下角
                animate={{ rotate: state.bed.angle }}
                transition={{ type: "spring", damping: 20, stiffness: 60 }}
              >
                {/* 枕头 */}
                <div className="absolute bottom-14 left-4 w-28 h-10 bg-white/90 rounded-2xl shadow-md" />
                
                {/* 用户的头部 */}
                <div className="absolute bottom-12 left-14 w-16 h-16 bg-slate-800 rounded-full" />
                
                {/* 盖在胸前的被子 */}
                <div className="w-full h-16 bg-indigo-900/90 rounded-tl-2xl rounded-bl-lg border-t-2 border-indigo-700/50 shadow-inner" />
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
              <div className="bg-black/30 backdrop-blur-xl px-5 py-3 rounded-full border border-white/10 flex items-center gap-3 text-sm text-white shadow-2xl">
                <Thermometer size={18} className={phase === 2 ? 'text-blue-400' : 'text-orange-400'} />
                <span>环境温控: <span className="font-medium tracking-wide">{state.bed.temp}</span></span>
              </div>
              <div className="bg-black/30 backdrop-blur-xl px-5 py-3 rounded-full border border-white/10 flex items-center gap-3 text-sm text-white shadow-2xl">
                <Volume2 size={18} className={phase === 2 ? 'text-slate-400' : 'text-emerald-400'} />
                <span>全景声场: <span className="font-medium tracking-wide">{state.tv.audio}</span></span>
              </div>
            </div>
          </div>

          {/* ========================================================= */}
          {/* 底部详细数据控制台 (Detailed Data Dashboard)                */}
          {/* ========================================================= */}
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-4 flex-shrink-0">
            
            {/* Device 1: Smart Ring */}
            <div className="bg-black/20 backdrop-blur-2xl border border-white/10 rounded-[1.5rem] p-5 relative overflow-hidden flex flex-col shadow-xl h-[420px]">
              <div className="absolute top-0 right-0 w-48 h-48 bg-rose-500/10 rounded-full blur-3xl -mr-16 -mt-16 pointer-events-none"></div>
              <div className="flex items-center gap-3 mb-4">
                <div className="p-2.5 bg-white/5 border border-white/10 rounded-xl text-rose-400 shadow-inner">
                  <HeartPulse size={20} />
                </div>
                <h2 className="text-base font-medium text-white tracking-wide">智能戒指 <span className="text-white/50 text-xs ml-2 font-normal">感知核心</span></h2>
              </div>
              
              <div className="flex-1 flex flex-col gap-4">
                <div className="flex justify-center items-center h-24">
                  {/* Breathing Halo */}
                  <motion.div className="relative flex items-center justify-center w-24 h-24">
                    <motion.div
                      className="absolute inset-0 rounded-full border border-rose-500/40"
                      animate={{ scale: [1, 1.6, 1], opacity: [0.5, 0, 0.5] }}
                      transition={{ repeat: Infinity, duration: 60 / state.ring.hr, ease: "easeInOut" }}
                    />
                    <motion.div
                      className="absolute inset-3 rounded-full border-2 border-rose-400/30 bg-rose-500/5"
                      animate={{ scale: [1, 1.3, 1], opacity: [0.8, 0, 0.8] }}
                      transition={{ repeat: Infinity, duration: 60 / state.ring.hr, ease: "easeInOut", delay: 0.2 }}
                    />
                    <div className="relative z-10 flex items-baseline gap-1 text-rose-400 drop-shadow-[0_0_10px_rgba(244,63,94,0.5)]">
                      <span className="text-4xl font-light tracking-tighter">{state.ring.hr}</span>
                      <span className="text-[10px] font-mono opacity-60 mb-1">BPM</span>
                    </div>
                  </motion.div>
                </div>

                <div className="grid grid-cols-2 gap-2">
                  <div className="bg-black/20 border border-white/5 rounded-xl p-3">
                    <div className="text-[10px] text-white/40 mb-1 uppercase tracking-wider">睡眠阶段</div>
                    <div className="text-xs font-medium text-indigo-300 truncate">{state.ring.stage}</div>
                  </div>
                  <div className="bg-black/20 border border-white/5 rounded-xl p-3">
                    <div className="text-[10px] text-white/40 mb-1 uppercase tracking-wider">心率变异性</div>
                    <div className="text-xs font-medium text-teal-300 truncate">{state.ring.hrv}</div>
                  </div>
                  <div className="bg-black/20 border border-white/5 rounded-xl p-3">
                    <div className="text-[10px] text-white/40 mb-1 uppercase tracking-wider">血氧饱和度</div>
                    <div className="text-xs font-medium text-blue-300 truncate">{state.ring.spo2}%</div>
                  </div>
                  <div className="bg-black/20 border border-white/5 rounded-xl p-3">
                    <div className="text-[10px] text-white/40 mb-1 uppercase tracking-wider">体表温度</div>
                    <div className="text-xs font-medium text-orange-300 truncate">{state.ring.temp}°C</div>
                  </div>
                </div>
              </div>
            </div>

            {/* Device 2: Smart Bed */}
            <div className="bg-black/20 backdrop-blur-2xl border border-white/10 rounded-[1.5rem] p-5 relative overflow-hidden flex flex-col shadow-xl h-[420px]">
              <div className="absolute top-0 right-0 w-48 h-48 bg-cyan-500/10 rounded-full blur-3xl -mr-16 -mt-16 pointer-events-none"></div>
              <div className="flex items-center gap-3 mb-4">
                <div className="p-2.5 bg-white/5 border border-white/10 rounded-xl text-cyan-400 shadow-inner">
                  <BedDouble size={20} />
                </div>
                <h2 className="text-base font-medium text-white tracking-wide">智能床 <span className="text-white/50 text-xs ml-2 font-normal">执行终端</span></h2>
              </div>
              
              <div className="flex-1 flex flex-col gap-3">
                
                {/* 可交互的床头仰角滑块 */}
                <div className="bg-black/20 border border-white/5 rounded-xl p-4 flex flex-col gap-3 relative overflow-hidden">
                  <div className="flex items-center justify-between">
                    <div>
                      <div className="text-[10px] text-white/40 mb-1 uppercase tracking-wider">床头仰角控制</div>
                      <div className="text-lg font-medium text-white">{state.bed.angle}°</div>
                    </div>
                    <div className="text-[10px] font-mono text-cyan-300 bg-cyan-500/10 border border-cyan-500/20 px-2 py-1 rounded-full">
                      {state.bed.angle === 15 ? '零重力/阅读' : state.bed.angle === 0 ? '平躺深睡' : '自定义'}
                    </div>
                  </div>
                  
                  <motion.div 
                    className="relative w-full py-2"
                    animate={shakeLock ? { x: [-5, 5, -5, 5, 0] } : {}}
                    transition={{ duration: 0.4 }}
                    onClickCapture={handleSliderInteraction}
                  >
                    <input
                      type="range"
                      min="0"
                      max="60"
                      value={state.bed.angle}
                      disabled={homeData.sleep_stage === 'DEEP_SLEEP'}
                      onMouseDown={() => setOriginalBedAngle(state.bed.angle)}
                      onTouchStart={() => setOriginalBedAngle(state.bed.angle)}
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
                      className={`w-full h-2.5 rounded-full appearance-none cursor-pointer outline-none transition-all duration-300 ${
                        homeData.sleep_stage === 'DEEP_SLEEP' 
                          ? 'bg-white/5 shadow-inner' 
                          : 'bg-white/10 accent-cyan-400 hover:bg-white/20'
                      }`}
                      style={homeData.sleep_stage === 'DEEP_SLEEP' ? { pointerEvents: 'none' } : {}}
                    />
                    {/* Hard Lock Icon Overlay */}
                    <AnimatePresence>
                      {homeData.sleep_stage === 'DEEP_SLEEP' && (
                        <motion.div 
                          initial={{ opacity: 0, scale: 0.8 }}
                          animate={{ opacity: 1, scale: 1 }}
                          exit={{ opacity: 0, scale: 0.8 }}
                          className="absolute inset-0 flex items-center justify-center pointer-events-none"
                        >
                          <div className="bg-black/60 backdrop-blur-md px-3 py-1.5 rounded-full flex items-center gap-2 border border-rose-500/30 shadow-lg">
                            <Lock size={14} className="text-rose-400" />
                            <span className="text-[10px] text-rose-300 font-medium tracking-wider">物理锁定</span>
                          </div>
                        </motion.div>
                      )}
                    </AnimatePresence>
                  </motion.div>
                </div>

                {/* Hide non-essential controls in DEEP_SLEEP */}
                <AnimatePresence>
                  {homeData.sleep_stage !== 'DEEP_SLEEP' && (
                    <motion.div 
                      initial={{ opacity: 0, height: 0 }}
                      animate={{ opacity: 1, height: 'auto' }}
                      exit={{ opacity: 0, height: 0 }}
                      className="flex flex-col gap-3 overflow-hidden"
                    >
                      <div className="bg-black/20 border border-white/5 rounded-xl p-3 flex items-center gap-3">
                        <div className="p-2 bg-indigo-500/10 rounded-lg"><Waves className="text-indigo-400" size={18} /></div>
                        <div>
                          <div className="text-[10px] text-white/40 mb-0.5 uppercase tracking-wider">震动反馈</div>
                          <div className="text-xs font-medium text-white">{state.bed.vibration}</div>
                        </div>
                      </div>
                      <div className="bg-black/20 border border-white/5 rounded-xl p-3 flex items-center gap-3">
                        <div className="p-2 bg-orange-500/10 rounded-lg"><Thermometer className="text-orange-400" size={18} /></div>
                        <div>
                          <div className="text-[10px] text-white/40 mb-0.5 uppercase tracking-wider">恒温系统</div>
                          <div className="text-xs font-medium text-white">{state.bed.temp}</div>
                        </div>
                      </div>
                      <div className="bg-black/20 border border-white/5 rounded-xl p-3 flex items-center gap-3">
                        <div className="p-2 bg-purple-500/10 rounded-lg"><Layers className="text-purple-400" size={18} /></div>
                        <div>
                          <div className="text-[10px] text-white/40 mb-0.5 uppercase tracking-wider">分区支撑度</div>
                          <div className="text-xs font-medium text-white">{state.bed.support_level}</div>
                        </div>
                      </div>
                    </motion.div>
                  )}
                </AnimatePresence>
              </div>
            </div>

            {/* Device 3: Smart TV */}
            <div className="bg-black/20 backdrop-blur-2xl border border-white/10 rounded-[1.5rem] p-5 relative overflow-hidden flex flex-col shadow-xl h-[420px]">
              <div className="absolute top-0 right-0 w-48 h-48 bg-amber-500/10 rounded-full blur-3xl -mr-16 -mt-16 pointer-events-none"></div>
              <div className="flex items-center gap-3 mb-4">
                <div className="p-2.5 bg-white/5 border border-white/10 rounded-xl text-amber-400 shadow-inner">
                  <Tv size={20} />
                </div>
                <h2 className="text-base font-medium text-white tracking-wide">智能电视 <span className="text-white/50 text-xs ml-2 font-normal">视听环境</span></h2>
              </div>
              
              <div className="flex-1 flex flex-col gap-3">
                <div className="bg-black/20 border border-white/5 rounded-xl p-4 flex items-center gap-3">
                  <div className="p-2 bg-amber-500/10 rounded-lg"><Sun className="text-amber-400" size={18} /></div>
                  <div className="flex-1">
                    <div className="text-[10px] text-white/40 mb-0.5 uppercase tracking-wider">屏幕画面</div>
                    <div className="text-xs font-medium text-white">{state.tv.visual}</div>
                  </div>
                  <div className="text-[10px] font-mono text-amber-300 bg-amber-500/10 border border-amber-500/20 px-2 py-1 rounded-full">
                    {state.tv.brightness}%
                  </div>
                </div>

                <AnimatePresence>
                  {homeData.sleep_stage !== 'DEEP_SLEEP' && (
                    <motion.div 
                      initial={{ opacity: 0, height: 0 }}
                      animate={{ opacity: 1, height: 'auto' }}
                      exit={{ opacity: 0, height: 0 }}
                      className="flex flex-col gap-3 overflow-hidden"
                    >
                      <div className="bg-black/20 border border-white/5 rounded-xl p-4 flex items-center gap-3">
                        <div className={`p-2 rounded-lg ${phase === 2 ? 'bg-white/5' : 'bg-emerald-500/10'}`}>
                          {phase === 2 ? <VolumeX className="text-white/40" size={18} /> : <Volume2 className="text-emerald-400" size={18} />}
                        </div>
                        <div>
                          <div className="text-[10px] text-white/40 mb-0.5 uppercase tracking-wider">音响系统</div>
                          <div className="text-xs font-medium text-white">{state.tv.audio}</div>
                        </div>
                      </div>
                      <div className="bg-black/20 border border-white/5 rounded-xl p-4 flex items-center gap-3">
                        <div className="p-2 bg-rose-500/10 rounded-lg"><Lightbulb className="text-rose-400" size={18} /></div>
                        <div>
                          <div className="text-[10px] text-white/40 mb-0.5 uppercase tracking-wider">背光氛围灯</div>
                          <div className="text-xs font-medium text-white">{state.tv.ambient_light}</div>
                        </div>
                      </div>
                    </motion.div>
                  )}
                </AnimatePresence>
              </div>
            </div>

          </div>
        </main>

        <footer className="text-center p-4 text-[10px] text-white/30 font-medium tracking-widest flex-shrink-0">
          ZERO-UI ARCHITECTURE · COMMERCIAL DEMO
        </footer>
      </div>
    </>
  );
}
